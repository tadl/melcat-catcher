class MelcatController < ApplicationController
respond_to :html, :json
require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'oj'
require 'nikkou'
require 'httparty'




def searchmelcat
headers['Access-Control-Allow-Origin'] = "*"
headers['Access-Control-Allow-Origin'] = "*"
headers['Access-Control-Request-Method'] = "*"
headers['Access-Control-Allow-Headers'] = "*"
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
@result_count = 10
end

if @count == "5"
@load_count = 45..-1
@result_count = 11
end




@pagetitle = 'http://elibrary.mel.org/search/a?searchtype=X&searcharg=' + @searchqueryclearned + '&SORT=D' 
url = @pagetitle
@doc = Nokogiri::HTML(open(url))
@itemlist = @doc.search('//tr[1]')[@load_count].text_includes("ISBN/ISSN:").first(@result_count).map do |item|
{
item:
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



@test = @pagetitle

respond_to do |format|
format.json { render :json => Oj.dump(items: @itemlist.uniq)  }
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

