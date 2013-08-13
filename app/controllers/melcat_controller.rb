class MelcatController < ApplicationController
respond_to :html, :json
require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'oj'
require 'nikkou'
require 'httparty'

before_filter :cors_preflight_check
after_filter :cors_set_access_control_headers

# For all responses in this controller, return the CORS access control headers.

def cors_set_access_control_headers
  headers['Access-Control-Allow-Origin'] = '*'
  headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
  headers['Access-Control-Max-Age'] = "1728000"
end

# If this is a preflight OPTIONS request, then short-circuit the
# request, return only the necessary headers and return an empty
# text/plain.

def cors_preflight_check
  if request.method == :options
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version'
    headers['Access-Control-Max-Age'] = '1728000'
    render :text => '', :content_type => 'text/plain'
  end
end




def searchmelcat

if params[:q].present?
@searchquery = params[:q]
@searchqueryclearned = CGI::escape(@searchquery)    
else
@searchqueryclearned = ""       
end 

@count = params[:count]

if @count == "1"
@load_count = 1..-1
@result_count = 10
end

if @count == "2"
@load_count = 15..-1
@result_count = 10
end

if @count == "3"
@load_count = 25..-1 
@result_count = 10
end

if @count == "4"
@load_count = 35..-1
@result_count = 8
end

if @count == "5"
@load_count = 45..-1
@result_count = 11
end




@pagetitle = 'http://elibrary.mel.org/search/a?searchtype=X&searcharg=' + @searchqueryclearned + '&SORT=D' 
url = @pagetitle
@doc = Nokogiri::HTML(open(url))

@checkpage = @doc.at_css(".bibSearchtoolMessage").try(:text).try(:strip)


if @checkpage == "1 result found.  Sorted by  relevance  | date  | title ."
@results = 1
@realcount = 1
else
@results = 2
@realcount = @doc.at_css(".browseSearchtoolMessage").try(:text).try(:strip).gsub(/[^0-9]/, "").to_i
end

if @count == "1"
@load_count = 1..-1
if @realcount >= 10
@result_count = 10
else
@result_count = @realcount
end
end

if @count == "2"
@load_count = 15..-1
if @realcount >= 20
@result_count = 10
else
@result_count = @realcount - 10
end
end

if @count == "3"
@load_count = 25..-1 
if @realcount >= 30
@result_count = 10
else
@result_count = @realcount - 20
end
end

if @count == "4"
@load_count = 35..-1
if @realcount >= 40
@result_count = 10
else
@result_count = @realcount - 30
end
end

if @count == "5"
@load_count = 45..-1
if @realcount >= 50
@result_count = 10
else
@result_count = @realcount - 40
end
end



if @results == 1
@how_many_results = 1
@itemlist = []
@itemlist = @doc.css("//div.bibContent[1]").map do |item|
{
:item =>
{
:title => item.search('table[1]/tr/td').text_includes("Title").after('td').next.next.next.try(:text).try(:strip),
:author => item.search('table[1]/tr/td').text_includes("Author").after('td').next.next.next.try(:text).try(:strip),
:publish => item.search('table[1]/tr/td').text_includes("Published").after('td').next.next.next.try(:text).try(:strip),
}
}
end 
@itemlist2 = []
@itemlist2 =  @doc.search('.bibInfo').map do |item|
#item.at_css('[@name="item_author"]').text.strip.try(:squeeze, " "),
{
:item =>
{
:link => CGI::escape('https://elibrary.mel.org'+item.at_css('[@name="summarytable"]').previous.previous['href']),
:available =>  HTTParty.get('http://tadl-ilscatcher.herokuapp.com/melcat/testmelcat.json?request_link=https://elibrary.mel.org/'+ CGI::escape(item.at_css('[@name="summarytable"]').previous.previous['href'])).body
}
}
end

@itemlist = Hash[*@itemlist]
@itemlist2 = Hash[*@itemlist2]

def merge_recursively(a, b)
  a.merge(b) {|key, a_item, b_item| merge_recursively(a_item, b_item) }
end

@itemlist = merge_recursively(@itemlist, @itemlist2)

end

if @results == 2

@how_many_results = @doc.at_css(".browseSearchtoolMessage").try(:text).try(:strip).gsub(/[^0-9]/, "").to_i


@itemlist = @doc.search('//tr[1]')[@load_count].text_includes("ISBN/ISSN:").first(@result_count).map do |item|
{
:item =>
{
:title => item.at_css('.briefcitTitle').try(:text).try(:strip),
:author => item.css('td[4]/br')[1].previous.try(:text).try(:strip),
:p_description => item.css('td[4]/br')[1].next.try(:text).try(:strip),
:isbn => item.css('td[4]/br')[2].next.try(:text).try(:strip).gsub(/[^0-9]/, ""),
:melcat_id => item.at_css('td[1]/input')['value'],
:link => CGI::escape(item.at_css('td[3]/a')['href']),
:available => HTTParty.get('http://tadl-ilscatcher.herokuapp.com/melcat/testmelcat.json?request_link='+ CGI::escape(item.at_css('td[3]/a')['href'])).body
}
}
end 

@itemlist = @itemlist.uniq
end


@test = @pagetitle

respond_to do |format|
format.json { render :json => { :message => @how_many_results, :items => @itemlist}  }
end
end


def testmelcat
@request_link = params[:request_link]
@request_url = URI::escape(@request_link)    
@checkpage = Nokogiri::HTML(open(@request_link))
if @checkpage.at_css('p:contains("Sorry")').present?
@gotit = "nope"
else
@gotit = "yep"
end
respond_to do |format|
format.json { render :json => Oj.dump(message: @gotit)  }
end
end

def hold
headers['Access-Control-Allow-Origin'] = "*"
@request_link = params[:request_link]
agent = Mechanize.new
page = agent.get(@request_link)
page.forms.class == Array
form = agent.page.forms[1]
form.field_with(:name => "campus").value = "zv330"
loginpage = agent.submit(form)
form = agent.page.forms[0]
form.field_with(:name => "name").value = "Scott"
form.field_with(:name => "code").value = 
form.field_with(:name => "loc").value = "v330w"
confirmpage = agent.submit(form)
doc = confirmpage.parser
@gotit = doc.search('p').text_includes("Your request for").try(:text).try(:strip)

respond_to do |format|

format.json { render :json => Oj.dump(:message => @gotit)  }
end
end















def showmelcat


@record_id = params[:record_id]
  

@pagetitle = 'http://elibrary.mel.org/record=' + @record_id 
url = @pagetitle
@doc = Nokogiri::HTML(open(url))
@request_link = @doc.css('//div.bibInfo/a')

if @doc.xpath("//*[@*[contains(., 'Holdings')]]").present?
@shelvinglocations = @doc.xpath("//*[@*[contains(., 'Holdings')]]").map do |detail|
if detail.at_css("td[5]").try(:text).try(:squeeze, " ") == "AVAILABLE" 
{
shelf_location:
{
:library => detail.at_css("td[1]").try(:text).try(:squeeze, " "),
:shelving_location => detail.at_css("td[2]").try(:text).try(:squeeze, " "),
:call_number => detail.at_css("td[4]").try(:text).try(:squeeze, " "),
:status => detail.at_css("td[5]").try(:text).try(:squeeze, " "),
}
}
end
end
@shelvinglocations_filtered = @shelvinglocations.compact.uniq
end

if @shelvinglocations_filtered.empty?
respond_to do |format|
format.json { render :json => Oj.dump(message: "none available")  }
end
else
respond_to do |format|
format.json { render :json => Oj.dump(available: @shelvinglocations_filtered)  }
end
end










end
end

