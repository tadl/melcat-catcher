class MainController < ApplicationController
respond_to :html, :json
require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'oj'
require 'nikkou'
require 'dalli'
require 'memcachier'

before_filter :set_cache_headers, :only => [:get_list] 
caches_action :get_list, :cache_path => Proc.new { |c| c.params }, :expires_in => 3.minutes, :race_condition_ttl => 1.minutes

def set_cache_headers
    headers['Access-Control-Allow-Origin'] = '*'      
end

def index
 
if params[:q].present?
@searchquery = params[:q]
@searchqueryclearned = CGI::escape(@searchquery)    
else
@searchqueryclearned = ""       
end    

if params[:sort].present?
 if params[:sort] == "RELEVANCE"
    @sorttype = "&sort="
    @sortdefault ="RELEVANCE" 
    elsif params[:sort] == "NEWEST TO OLDEST"
    @sorttype = "&sort=pubdate.descending"
    @sortdefault ="NEWEST TO OLDEST" 
    elsif params[:sort] == "OLDEST TO NEWEST"
    @sorttype = "&sort=pubdate"
    @sortdefault ="OLDEST TO NEWEST" 
    else
    @sorttype = "&sort="
    @sortdefault ="RELEVANCE" 
    end
else
@sorttype=""
end

if params[:mt].present?    
    if params[:mt] == "MOVIES"
    @mediatype = "format=g"
    @fdefault ="MOVIES"    
    elsif params[:mt] == "BOOKS"
    @mediatype = "format=at"
    @fdefault = "BOOKS"
    elsif params[:mt] == "MUSIC"
    @mediatype = "format=j"
    @fdefault = "MUSIC"
    elsif params[:mt] == "VIDEO GAMES"
    @mediatype = "format=mVG&facet=subject%7Cgenre%5Bgame%5D"
    @fdefault = "VIDEO GAMES" 
    elsif params[:mt] == "ALL"
    @mediatype = "format="
    @fdefault = "ALL" 
    end
end

if params[:st].present? 
if params[:st] == "KEYWORD"
@searchby = "&qtype=keyword"
@stdefault = "KEYWORD"
elsif params[:st] == "TITLE"
@searchby = "&qtype=title"
@stdefault = "TITLE"
elsif params[:st] == "AUTHOR/ARTIST"
@searchby = "&qtype=author"
@stdefault = "AUTHOR/ARTIST"
end
else
@searchby = "&qtype=keyword"
@stdefault = "KEYWORD"
end

if params[:avail]
@avail = "&modifier=available"
else
@avail = ""
end


  
if params[:q].present? && params[:mt].present?

@pagetitle = 'http://catalog.tadl.org/eg/opac/results?query=' + @searchqueryclearned + '' +  @searchby + '&fi%3A'+ @mediatype +''+ @avail +'&locg=22&limit=24' + @sorttype +''
url = @pagetitle
@doc = Nokogiri::HTML(open(url))
@pagenumber = @doc.at_css(".results-paginator-selected").text rescue nil
@querytitle = @pagetitle.gsub("http://catalog.tadl.org/", '') 
@querytitle2 = @querytitle.gsub(".", '%2E')  
@cleanquerytitle = CGI::escape(@querytitle2)
elsif params[:mt].present?
@pagetitle = 'http://catalog.tadl.org/eg/opac/results?query=&qtype=keyword&fi%3A'+ @mediatype +''+ @avail +'&locg=22&limit=24' + @sorttype +''
url = @pagetitle
@doc = Nokogiri::HTML(open(url))  
@pagenumber = @doc.at_css(".results-paginator-selected").text rescue nil
@querytitle = @pagetitle.gsub("http://catalog.tadl.org/", '') 
@querytitle2 = @querytitle.gsub(".", '%2E')  
@cleanquerytitle = CGI::escape(@querytitle2)

end
end

def showmore
end

def about
end

def searchjson
headers['Access-Control-Allow-Origin'] = "*"
 
if params[:q].present?
@searchquery = params[:q]
@searchqueryclearned = CGI::escape(@searchquery)    
else
@searchqueryclearned = ""       
end    

if params[:p].present?
@nextpage = params[:p]
else
@nextpage = "0"
end

if params[:loc].present?
@loc = params[:loc]
else
@loc = "22"
end


 if params[:sort] == "relevance"
    @sorttype = "&sort="
 elsif params[:sort] == "newest_to_oldest"
    @sorttype = "&sort=pubdate.descending"
 elsif params[:sort] == "oldest_to_newest"
    @sorttype = "&sort=pubdate"
 elsif params[:sort] == "title_az"
 	@sorttype = "&sort=titlesort"
 elsif params[:sort] == "title_za"
 	@sorttype = "&sort=titlesort.descending"
 elsif params[:sort] == "author_az"
 	@sorttype = "&sort=authorsort"
 elsif params[:sort] == "author_za"
 	@sorttype = "&sort=authorsort.descending"
 else
 	@sorttype = ""
 end



if params[:mt].present?    
    if params[:mt] == "MOVIES"
    @mediatype = "format=g"
    @fdefault ="MOVIES"    
    elsif params[:mt] == "BOOKS"
    @mediatype = "format=at"
    @fdefault = "BOOKS"
    elsif params[:mt] == "MUSIC"
    @mediatype = "format=j"
    @fdefault = "MUSIC"
    elsif params[:mt] == "VIDEO GAMES"
    @mediatype = "format=mVG&facet=subject%7Cgenre%5Bgame%5D"
    @fdefault = "VIDEO GAMES" 
    elsif params[:mt] == "ALL FORMATS"
    @mediatype = "format="
    @fdefault = "ALL" 
    end
    else 
    @mediatype = "format="
end

if params[:st].present? 
if params[:st] == "keyword"
@searchby = "&qtype=keyword"
@stdefault = "KEYWORD"
elsif params[:st] == "title"
@searchby = "&qtype=title"
@stdefault = "TITLE"
elsif params[:st] == "author"
@searchby = "&qtype=author"
@stdefault = "AUTHOR/ARTIST"
elsif params[:st] == "subject"
@searchby = "&qtype=subject"
@stdefault = "SUBJECT"
end
else
@searchby = "&qtype=keyword"
@stdefault = "KEYWORD"
end

if params[:avail] == "true"
@avail = "&modifier=available"
else
@avail = ""
end

if params[:facet].present?
@facet = params[:facet]
else
@facet = ""
end


  
if params[:q].present? 

@pagetitle = 'http://catalog.tadl.org/eg/opac/results?query=' + @searchqueryclearned + '' +  @searchby + '&fi%3A'+ @mediatype +''+ @avail +'&locg='+ @loc +'&limit=24'+ @sorttype +'&page='+ @nextpage +'&'+@facet 
url = @pagetitle
@doc = Nokogiri::HTML(open(url))
@pagenumber = @doc.at_css(".results-paginator-selected").text rescue nil
elsif params[:mt].present?
@pagetitle = 'http://catalog.tadl.org/eg/opac/results?query=&qtype=keyword&fi%3A'+ @mediatype +''+ @avail +'&locg='+ @loc +'&limit=24'+ @sorttype +'&page='+ @nextpage +'&facet='+ @facet
url = @pagetitle
@doc = Nokogiri::HTML(open(url))  
@pagenumber = @doc.at_css(".results-paginator-selected").text rescue nil
end

@itemlist = @doc.css(".result_table_row").map do |item| 
{
item:
{
:title => item.at_css(".bigger").text.strip, 
:author => item.at_css('[@name="item_author"]').text.strip.try(:squeeze, " "),
:availability => item.at_css(".result_count").try(:text).try(:strip).try(:gsub!, /in TADL district./," "), 
:online => item.search('a').text_includes("Connect to this resource online").first.try(:attr, "href"),
:record_id => item.at_css(".search_link").attr('name').sub!(/record_/, ""),
:image => item.at_css(".result_table_pic").try(:attr, "src").try(:gsub, /^\//, "http://catalog.tadl.org/"),
:abstract => item.at_css('[@name="bib_summary"]').try(:text).try(:strip).try(:squeeze, " "),
:contents => item.at_css('[@name="bib_contents"]').try(:text).try(:strip).try(:squeeze, " "),
:record_year => item.at_css(".record_year").try(:text),
:format_icon => item.at_css(".result_table_title_cell img").try(:attr, "src").try(:gsub, /^\//, "http://catalog.tadl.org/")
}
}
end 




@subjectlist = @doc.css(".facet_box_temp").map do |item|
@facetcount = 0;
group={}
group['title'] = item.at_css('.header').text.strip.try(:squeeze, " ")
group['facets'] = item.css("div.facet_template:not(.facet_template_selected)").map do |facet|
child_facet = {}
child_facet['facet'] = facet.at_css('.facet').text.strip.try(:squeeze, " ")
child_facet['links'] = facet.css('a').map do |link|
child_facet_link = {}
child_facet_link['link'] = CGI::escape(link.attr('href').split(';', 5)[4])
@facetcount = @facetcount + 1
child_facet_link
end
child_facet
end
group['count'] = @facetcount;
group
end

@selectedfacets = @doc.css("div.facet_template.facet_template_selected").map do |item|
{
facets:
{
:title => item.at_css('.facet').text.strip.try(:squeeze, " "),
:link => CGI::escape(item.at_css('div.facet a').attr('href').split(';', 5)[4])
}
}
end

if @doc.css('.invisible:contains(" Next ")').present?
	@more_results = 'false'
else
	@more_results = 'true'
end



if @itemlist.count == 0

respond_to do |format|
format.json { render :json => { :status => :error, :message => "no results" }}
end


else

respond_to do |format|
format.json { render :json => {:items => @itemlist, :subjects => @subjectlist, :selected => @selectedfacets, :more_results => @more_results }}
end

end
end

def itemdetails
headers['Access-Control-Allow-Origin'] = "*"
@gottem = "gottem"
@nope = "nope"
fix = %q[subject')"]
@record_id = params[:record_id]
@pagetitle = 'http://catalog.tadl.org/eg/opac/record/' + @record_id + '?locg=22;copy_offset=0;copy_limit=75'
url = @pagetitle
@doc = Nokogiri::HTML(open(url)) 
@record_details = @doc.css("#main-content").map do |detail|

{
:author => detail.at_css(".rdetail_authors_div").css('a').try(:to_s).try(:gsub, /\n/, "").try(:gsub,'<a href="/eg/opac/results?locg=22;copy_offset=0;copy_limit=75;','<a onclick="subject_search("').try(:gsub, 'itemprop="contributor"',')"').try( :gsub, 'subject"',"#{fix}"),
:title => detail.at_css("#rdetail_title").text,
:summary => detail.at_css("#rdetail_summary_from_rec").try(:text).try(:strip),
:contents => detail.at_css("rdetail_contents_from_rec").try(:text).try(:strip),
:record_id => @record_id,
:copies_available => detail.at_css(".rdetail_aux_copycounts").try(:text).try(:strip).try(:gsub!, /available in District./," ").try(:squeeze, " ").try(:strip),
:copies_total => detail.at_css(".rdetail_aux_holdcounts").try(:text).try(:strip).try(:split, "on ").try(:last).try(:gsub, /copies./," ").try(:gsub, /copy./," ").try(:strip),
:eresource => detail.at_css('/div[2]/p/a').try(:attr, "href"),
:image => detail.at_css('#rdetail_image').try(:attr, "src").try(:gsub, /^\//, "http://catalog.tadl.org/"),
:format_icon => detail.at_css('.format_icon/img').try(:attr, "src").try(:gsub, "/images/format_icons/item_type/", ""),
:record_year => detail.search('span[@itemprop="datePublished"]').try(:text),
:publisher => detail.search('span[@itemprop="publisher"]').try(:text),
:isbn => detail.search('span[@itemprop="isbn"]').to_s.try(:gsub, "<span class=\"rdetail_value\" itemprop=\"isbn\">", "").try(:gsub, "</span>", ", "),
:physical_description => detail.at('td:contains("Physical Description")').try(:next_element).try(:text),
:related_subjects => detail.at('td:contains("Subject:")').try(:next_element).try(:to_s).try(:strip).try(:gsub, /\n/, "").try(:gsub,'<a href="/eg/opac/results?locg=22;copy_offset=0;copy_limit=75;','<a onclick="subject_search("').try(:gsub, '"query=',"'").try( :gsub, 'subject"',"#{fix}"),
:related_genres => detail.at('td:contains("Genre:")').try(:next_element).try(:to_s).try(:strip).try(:gsub, /\n/, "").try(:gsub,'<a href="/eg/opac/results?locg=22;copy_offset=0;copy_limit=75;','<a onclick="subject_search("').try(:gsub, '"query=',"'").try( :gsub, 'subject"',"#{fix}"),

}

end

if @doc.css('//table#rdetails_status//tr').present?
@shelvinglocations = @doc.css('//table#rdetails_status//tr')[1..-1].map do |detail|
if detail.at_css("td[4]").try(:text).try(:squeeze, " ") == "Available" || detail.at_css("td[4]").try(:text).try(:squeeze, " ") == "Reshelving"
{
shelf_location:
{
:library => detail.at_css("td[1]").try(:text).try(:rstrip),
:shelving_location => detail.at_css("td[3]").try(:text).try(:squeeze, " "),
:call_number => detail.at_css("td[2]").try(:text).try(:rstrip),
:available => detail.at_css("td[4]").try(:text).try(:squeeze, " "),
}
}
end
end
@shelvinglocations_filtered = @shelvinglocations.compact.uniq
end


respond_to do |format|
format.json { render :json =>{:items => @record_details, :shelvinglocations => @shelvinglocations_filtered }}
end
end


def itemonshelf
headers['Access-Control-Allow-Origin'] = "*"
@record_id = params[:record_id]
@pagetitle = 'http://catalog.tadl.org/eg/opac/record/' + @record_id + '?locg=22;copy_offset=0;copy_limit=75'
url = @pagetitle
agent = Mechanize.new
itempage = agent.get(url)
@doc = itempage.parser
@record_details = @doc.css('//table#rdetails_status//tr')[1..-1].map do |detail|
if detail.at_css("td[4]").try(:text).try(:squeeze, " ") == "Available" || detail.at_css("td[4]").try(:text).try(:squeeze, " ") == "Reshelving"
{
item:
{
:library => detail.at_css("td[1]").try(:text).try(:squeeze, " "),
:shelving_location => detail.at_css("td[3]").try(:text).try(:squeeze, " "),
:call_number => detail.at_css("td[2]").try(:text).try(:squeeze, " "),
:available => detail.at_css("td[4]").try(:text).try(:squeeze, " "),
}
}
end
end
@filtered = @record_details.compact
respond_to do |format|
format.json { render :json => Oj.dump(items: @filtered.uniq)  }
end
end

def marc
headers['Access-Control-Allow-Origin'] = "*"
@record_id = params[:record_id]
@pagetitle = 'http://catalog.tadl.org/eg/opac/record/' + @record_id + '?expand=marchtml#marchtml'
url = @pagetitle
agent = Mechanize.new
itempage = agent.get(url)
@doc = itempage.parser
@marc = @doc.at_css('.marc_table').to_s.gsub(/\n/,'').gsub(/\t/,'')

respond_to do |format|
format.json { render :json => {:marc => @marc}}
end

end



def hold
headers['Access-Control-Allow-Origin'] = "*"
@username = params[:u]
@password = params[:pw]
@record_id = params[:record_id]
agent = Mechanize.new
page = agent.get("https://catalog.tadl.org/eg/opac/login?redirect_to=%2Feg%2Fopac%2Fmyopac%2Fmain")
page.forms.class == Array
form = agent.page.forms[1]
form.field_with(:name => "username").value = @username
form.field_with(:name => "password").value = @password
results = agent.submit(form)
holdpage = agent.get('https://catalog.tadl.org/eg/opac/place_hold?;locg=22;hold_target='+ @record_id +';hold_type=T;')
holdform = agent.page.forms[1]  
holdconfirm = agent.submit(holdform)
@doc = holdconfirm.parser
@confirm_message = @doc.css("#hold-items-list").text.try(:gsub!, /\n/," ").try(:squeeze, " ").try(:strip).try(:split, ". ").try(:last)
respond_to do |format|
format.json { render :json => Oj.dump(:message => @confirm_message)  }
end
end

def multihold
headers['Access-Control-Allow-Origin'] = "*"
@username = params[:u]
@password = params[:pw]
@record_id = params[:record_id]
@split_ids = @record_id.split(",").map(&:strip).reject(&:empty?)
@split_formated = @split_ids.map! { |k| "&hold_target=#{k}" }.join
agent = Mechanize.new
page = agent.get("https://catalog.tadl.org/eg/opac/login?redirect_to=%2Feg%2Fopac%2Fmyopac%2Fmain")
page.forms.class == Array
form = agent.page.forms[1]
form.field_with(:name => "username").value = @username
form.field_with(:name => "password").value = @password
results = agent.submit(form)
holdpage = agent.get('https://catalog.tadl.org/eg/opac/place_hold?hold_type=T&loc=22'+@split_formated)
holdform = agent.page.forms[1]  
holdconfirm = agent.submit(holdform)
@doc = holdconfirm.parser
@confirm_message = @doc.css("#hold-items-list").text.try(:gsub!, /\n/," ").try(:squeeze, " ").try(:strip).try(:split, ". ").try(:last)
@record_details = @doc.css('//table#hold-items-list//tr').map do |detail|

{
:record_id => detail.at_css("td[1]//input").try(:attr, "value"),
:title => detail.at_css("td[2]").try(:text).try(:gsub!, /\n/," ").try(:squeeze, " ").try(:strip).try(:split, ". ").try(:first),
:message => detail.at_css("td[2]").try(:text).try(:gsub!, /\n/," ").try(:squeeze, " ").try(:strip).try(:split, ". ").try(:last),
}

end

respond_to do |format|
format.json { render :json => {:items => @record_details}  }
end
end


def renew
headers['Access-Control-Allow-Origin'] = "*"
@username = params[:u]
@password = params[:pw]
@circ_id = params[:circ_id]
@barcode = params[:bc]
agent = Mechanize.new
page = agent.get("https://catalog.tadl.org/eg/opac/login?redirect_to=%2Feg%2Fopac%2Fmyopac%2Fmain")
page.forms.class == Array
form = agent.page.forms[1]
form.field_with(:name => "username").value = @username
form.field_with(:name => "password").value = @password
results = agent.submit(form)
renew = agent.get('https://catalog.tadl.org/eg/opac/myopac/circs?&action=renew&circ='+ @circ_id +'')
@doc = renew.parser
@renew_summary = @doc.css(".renew-summary").text
@checkouts = @doc.search('tr').text_includes(@barcode).map do |checkout|
{
checkout:
{
:name => checkout.at_css("/td[2]").try(:text).try(:strip).try(:gsub!, /\n/," ").try(:squeeze, " "),
:renew_attempts => checkout.css("/td[4]").text.to_s.try(:gsub!, /\n/," ").try(:squeeze, " ").try(:strip),
:due_date => checkout.css("/td[5]").text.to_s.try(:gsub!, /\n/," ").try(:squeeze, " ").try(:strip),
:checkout_id => checkout.at('td[1]/input')['value'],
:barcode => checkout.css("/td[6]").text.to_s.try(:gsub!, /\n/," ").try(:squeeze, " ").try(:strip),
}
}
end

respond_to do |format|
format.json { render :json => Oj.dump(:checkouts => @checkouts, :response => @renew_summary)}   
end
end

def cancelhold
headers['Access-Control-Allow-Origin'] = "*"
@username = params[:u]
@password = params[:pw]
@hold_id = params[:hold_id]
agent = Mechanize.new
page = agent.get("https://catalog.tadl.org/eg/opac/login?redirect_to=%2Feg%2Fopac%2Fmyopac%2Fmain")
page.forms.class == Array
form = agent.page.forms[1]
form.field_with(:name => "username").value = @username
form.field_with(:name => "password").value = @password
results = agent.submit(form)
renew = agent.get('https://catalog.tadl.org/eg/opac/myopac/holds?&action=cancel&hold_id='+ @hold_id +'')

respond_to do |format|
format.json { render :json => Oj.dump("Hello")}   
end


end

def login
headers['Access-Control-Allow-Origin'] = "*"
agent = login_action(params[:u],params[:pw])
page = agent.get("https://catalog.tadl.org")
@doc = page.parser

@user = @doc.css("body").map do |item| 
{
user:
{
:name => item.at_css('#dash_user').try(:text).try(:strip),
:checkouts => item.at_css('#dash_checked').try(:text).try(:strip),
:holds => item.at_css('#dash_holds').try(:text).try(:strip),
:pickups => item.at_css('#dash_pickup').try(:text).try(:strip),
:fines => item.at_css('#dash_fines').try(:text).try(:strip),
}
}
end

agent = login_action(params[:u],params[:pw])
test = agent.cookies.detect { |t| t.name == 'ses' }

if @user.count == 0 || @user[0][:user][:name] == nil

respond_to do |format|
format.json { render :json => { :status => :error, :message => "Bad Login or Password" }}
end
else

respond_to do |format|
format.json { render :json => { :users => @user, :token => test.value }}
end
end
end

def showcheckouts
headers['Access-Control-Allow-Origin'] = "*"
@username = params[:u]
@password = params[:pw]
agent = Mechanize.new
page = agent.get("https://catalog.tadl.org/eg/opac/login?redirect_to=%2Feg%2Fopac%2Fmyopac%2Fmain")
form = agent.page.forms[1]
form.field_with(:name => "username").value = @username
form.field_with(:name => "password").value = @password
results = agent.submit(form)
checkoutpage = agent.get("https://catalog.tadl.org/eg/opac/myopac/circs?loc=22")
@doc = checkoutpage.parser
@pagetitle = @doc.css("title").text
@checkouts = @doc.css('//table[1]/tr')[1..-1].map do |checkout|
{
checkout:
{
:checkout_id => checkout.at('td[1]/input')['value'],
:name => checkout.css("/td[2]").try(:text).try(:gsub!, /\n/," ").try(:squeeze, " "),
:image => checkout.at_css("/td[2]/a/img").try(:attr, "src").try(:gsub, /^\//, "http://catalog.tadl.org/"),
:renew_attempts => checkout.css("/td[4]").text.to_s.try(:gsub!, /\n/," ").try(:squeeze, " ").try(:strip),
:due_date => checkout.css("/td[5]").text.to_s.try(:gsub!, /\n/," ").try(:squeeze, " ").try(:strip),
:format_icon => checkout.css("/td[3]/img").attr("src").text.try(:gsub, /^\//, "http://catalog.tadl.org/"),
:barcode => checkout.css("/td[6]").text.to_s.try(:gsub!, /\n/," ").try(:squeeze, " ").try(:strip),
}
}
end 

respond_to do |format|
format.json { render :json => Oj.dump(checkouts: @checkouts)}
end
end

def showholds
headers['Access-Control-Allow-Origin'] = "*"
@username = params[:u]
@password = params[:pw]
agent = Mechanize.new
page = agent.get("https://catalog.tadl.org/eg/opac/login?redirect_to=%2Feg%2Fopac%2Fmyopac%2Fmain")
form = agent.page.forms[1]
form.field_with(:name => "username").value = @username
form.field_with(:name => "password").value = @password
results = agent.submit(form)
checkoutpage = agent.get("https://catalog.tadl.org/eg/opac/myopac/holds?loc=22")
@doc = checkoutpage.parser
@pagetitle = @doc.css("title").text
@holds = @doc.css('tr#acct_holds_temp').map do |checkout|
{
hold:
{
:hold_id => checkout.at('td[1]/div/input')['value'],
:name => checkout.css("/td[2]").try(:text).try(:gsub!, /\n/," ").try(:squeeze, " "),
:image => checkout.at_css("/td[2]/div/a/img").try(:attr, "src").try(:gsub, /^\//, "http://catalog.tadl.org/"),
:author => checkout.css("/td[3]").text.to_s.try(:gsub!, /\n/," ").try(:squeeze, " ").try(:strip),
:format_icon => checkout.css("/td[4]/div/img").attr('src').text.try(:gsub, /^\//, "http://catalog.tadl.org/"),
:pickup_location => checkout.css("/td[5]").text.to_s.try(:gsub!, /\n/," ").try(:squeeze, " ").try(:strip),
:status => checkout.css("/td[9]").text.to_s.try(:gsub!, /\n/," ").try(:squeeze, " ").try(:strip).try(:gsub, /([0-9]{2}\/[0-9]{2}\/[0-9]{4}).*/, "\\1").try(:gsub, /hold/,"in line waiting").try(:gsub, /Waiting for copy/,"You are number").try(:gsub, /AvailableExpires/,"Ready for Pickup. Expires on"),
}
}
end 

respond_to do |format|
format.json { render :json => Oj.dump(holds: @holds)}
end
end


def showpickups

headers['Access-Control-Allow-Origin'] = "*"
@username = params[:u]
@password = params[:pw]
agent = Mechanize.new
page = agent.get("https://catalog.tadl.org/eg/opac/login?redirect_to=%2Feg%2Fopac%2Fmyopac%2Fmain")
form = agent.page.forms[1]
form.field_with(:name => "username").value = @username
form.field_with(:name => "password").value = @password
results = agent.submit(form)
checkoutpage = agent.get("https://catalog.tadl.org/eg/opac/myopac/holds?available=1")
@doc = checkoutpage.parser
@pagetitle = @doc.css("title").text
@holds = @doc.css('tr#acct_holds_temp').map do |checkout|
{
hold:
{
:hold_id => checkout.at('td[1]/div/input')['value'],
:name => checkout.css("/td[2]").try(:text).try(:gsub!, /\n/," ").try(:squeeze, " "),
:author => checkout.css("/td[3]").text.to_s.try(:gsub!, /\n/," ").try(:squeeze, " ").try(:strip),
:format_icon => checkout.css("/td[4]/div/img").attr('src').text.try(:gsub, /^\//, "http://catalog.tadl.org/"),
:image => checkout.at_css("/td[2]/div/a/img").try(:attr, "src").try(:gsub, /^\//, "http://catalog.tadl.org/"),
:pickup_location => checkout.css("/td[5]").text.to_s.try(:gsub!, /\n/," ").try(:squeeze, " ").try(:strip),
:status => checkout.css("/td[9]").text.to_s.try(:gsub!, /\n/," ").try(:squeeze, " ").try(:strip).try(:gsub, /([0-9]{2}\/[0-9]{2}\/[0-9]{4}).*/, "\\1").try(:gsub, /hold/,"in line waiting").try(:gsub, /Waiting for copy/,"You are number").try(:gsub, /AvailableExpires/,"Ready for Pickup. Expires on"),
}
}
end 

respond_to do |format|

format.json { render :json => Oj.dump(holds: @holds)}
end
end

def showcard
headers['Access-Control-Allow-Origin'] = "*"
@username = params[:u]
@password = params[:pw]
agent = Mechanize.new
page = agent.get("https://catalog.tadl.org/eg/opac/login?redirect_to=%2Feg%2Fopac%2Fmyopac%2Fmain")
form = agent.page.forms[1]
form.field_with(:name => "username").value = @username
form.field_with(:name => "password").value = @password
results = agent.submit(form)
accountdetails = agent.get("https://catalog.tadl.org/eg/opac/myopac/prefs?loc=22")
@doc = accountdetails.parser
@barcode = @doc.css('.active_barcode').text
respond_to do |format|
format.json { render :json => { :barcode => @barcode}}
end
end

def search_prefs
headers['Access-Control-Allow-Origin'] = "*"
agent = login_action(params[:u],params[:pw])

if params[:new_search_prefs]
	options = params[:new_search_prefs].split(',')

	if options[1] == 'true'
	circ_retention = 'on'
	else
	circ_retention = 'off'
	end
	
	if options[2] == 'true'
	hold_retention = 'on'
	else
	hold_retention = 'off'
	end
	
	
	attack = agent.post('https://catalog.tadl.org/eg/opac/myopac/prefs_settings', { 
		"opac.default_pickup_location" => options[0],
		"history.circ.retention_start" => circ_retention,
		"history.hold.retention_start" => hold_retention,
	})

end

if params[:new_email]	
	attack = agent.post('https://catalog.tadl.org/eg/opac/myopac/update_email', { 
		"email" => params[:new_email],
		"current_pw" => params[:pw],
	})
end

if params[:new_alias]	
	page = agent.get("https://catalog.tadl.org/eg/opac/myopac/update_alias")
	form = agent.page.forms[1]
	form.field_with(:name => "alias").value = params[:new_alias]
	form.field_with(:name => "current_pw").value = params[:pw]
	agent.submit(form)
end

if params[:new_username]


end

if params[:new_notify_prefs]
	options = params[:new_notify_prefs].split(',')

	if options[0] == 'true'
	phone_notify = 'on'
	else
	phone_notify = 'off'
	end
	
	if options[1] == 'true'
	email_notify = 'on'
	else
	email_notify = 'off'
	end
	
	
	attack = agent.post('https://catalog.tadl.org/eg/opac/myopac/prefs_notify', {
		"opac.hold_notify.email" => email_notify,
		"opac.hold_notify.phone" => phone_notify,
	})

end





page = agent.get("https://catalog.tadl.org/eg/opac/myopac/prefs_settings")
@doc = page.parser
@pagetitle = @doc.css("title").text
@hits_setting = @doc.css('select[@name="opac.hits_per_page"] option[@selected="selected"]').attr('value').text
@search_setting = @doc.css('select[@name="opac.default_search_location"] option[@selected="selected"]').attr('value').text
@pickup_setting = @doc.css('select[@name="opac.default_pickup_location"] option[@selected="selected"]').attr('value').text
if @doc.css('input[@name="history.circ.retention_start"]').attr('checked')
@circ_setting = "on"
else
@circ_setting = "off"
end
if @doc.css('input[@name="history.hold.retention_start"]').attr('checked')
@hold_setting = "on"
else
@hold_setting = "off"
end

page = agent.get("https://catalog.tadl.org/eg/opac/myopac/prefs_notify")
@doc = page.parser
if @doc.css('input[@name="opac.hold_notify.email"]').attr('checked')
@hold_notify_email = "on"
else
@hold_notify_email = "off"
end

if @doc.css('input[@name="opac.hold_notify.phone"]').attr('checked')
@hold_notify_phone = "on"
else
@hold_notify_phone = "off"
end
page = agent.get("https://catalog.tadl.org/eg/opac/myopac/prefs")
@doc = page.parser
@default_phone = @doc.at_css('td:contains("Day Phone")').try(:next_element).try(:text)
@opac_username = @doc.at_css('td:contains("Username")').try(:next_element).try(:text)
@email_address = @doc.at_css('td:contains("Email Address")').try(:next_element).try(:text)
@hold_shelf_alias = @doc.at_css('td:contains("Holdshelf Alias")').try(:next_element).try(:text)











respond_to do |format|
format.json { render :json => { :settings => {  
:pickup => @pickup_setting, 
:circ => @circ_setting, 
:hold => @hold_setting, 
:hold_notify_email => @hold_notify_email,
:hold_notify_phone => @hold_notify_phone,
:opac_username => @opac_username,
:hold_shelf_alias => @hold_shelf_alias,
:email_address => @email_address,
} } }
end
end


def login_action(username, password)
agent = Mechanize.new
page = agent.get("https://catalog.tadl.org/eg/opac/login?redirect_to=%2Feg%2Fopac%2Fmyopac%2Fmain")
form = agent.page.forms[1]
form.field_with(:name => "username").value = username
form.field_with(:name => "password").value = password
form.checkbox_with(:name => "persist").check
agent.submit(form)
return agent
end


def create_list
agent = login_action(params[:u],params[:pw])
agent.post('/eg/opac/myopac/list/update?loc=22', { 
"loc" => '22',
"name" => params[:title],
"action" => 'create',
"description" => params[:desc],
"shared" => params[:share]
})
list_page = agent.get('https://catalog.tadl.org/eg/opac/myopac/lists?')
doc = list_page.parser
list_title = 'a:contains("'+params[:title]+'")'
list_id = doc.at_css(list_title).attr('href').gsub('/eg/opac/myopac/lists?bbid=','')

respond_to do |format|
format.json { render :json =>{:list_id => list_id}}
end

end

def add_to_list

record_id_container = ''
record_ids = params[:record_ids].split(',')
record_ids.each do |r| 
record = 'record=' + r + '&'
record_id_container = record_id_container + record
end

list_url = URI.encode('https://catalog.tadl.org/eg/opac/myopac/lists?loc=22;bbid=' + params[:list_id])
add_to_list_url = URI.encode('https://catalog.tadl.org/eg/opac/mylist/add?loc=22;record=' + record_ids[0])
post_url = URI.encode('https://catalog.tadl.org/eg/opac/mylist/move?action='+ params[:list_id] +'&loc=22&'+ record_id_container)

agent = login_action(params[:u],params[:pw])
agent.get(add_to_list_url)
agent.get(post_url, [], list_url) 

respond_to do |format|
format.json { render :json =>{:message => @post_url}}
end

end


def get_list
	if params[:page]
	page = params[:page]
	else
	page = 0
	end
	if params[:available] == 'yes'
	available = '&modifier=available'
	else
	available = ''
	end
	list_id = params[:list_id].to_s
	page_number = page.to_s
	
	url = 'https://catalog.tadl.org/eg/opac/results?bookbag='+ list_id +'&limit=24' + available +'&page='+ page_number +'&locg=22'
	
	agent = Mechanize.new
	page = agent.get(url)
	doc = page.parser
	
	
	list_name = doc.css(".result-bookbag-name").text
	list_id = list_id
	if params[:just_ids] == 'yes'
	
		itemlist = doc.css(".result_table_row").take(6).map do |item| 
			{
			:record_id => item.at_css(".search_link").attr('name').sub!(/record_/, ""),
			}
		end 
	else
		itemlist = doc.css(".result_table_row").map do |item| 
			{
			:title => item.at_css(".bigger").text.strip, 
			:author => item.at_css('[@name="item_author"]').text.strip.try(:squeeze, " "),
			:availability => item.at_css(".result_count").try(:text).try(:strip).try(:gsub!, /in TADL district./," "), 
			:online => item.search('a').text_includes("Connect to this resource online").first.try(:attr, "href"),
			:record_id => item.at_css(".search_link").attr('name').sub!(/record_/, ""),
			:list_item_id => item.at_css(".list-item-id").attr('title'),
			:image => item.at_css(".result_table_pic").try(:attr, "src").try(:gsub, /^\//, "http://catalog.tadl.org/"),
			:abstract => item.at_css('[@name="bib_summary"]').try(:text).try(:strip).try(:squeeze, " "),
			:contents => item.at_css('[@name="bib_contents"]').try(:text).try(:strip).try(:squeeze, " "),
			:record_year => item.at_css(".record_year").try(:text),
			:format_icon => item.at_css(".result_table_title_cell img").try(:attr, "src").try(:gsub, /^\//, "http://catalog.tadl.org/")
			}
		end 
	end
	respond_to do |format|
		format.json { render :json =>{:list_name => list_name, :list_id => list_id, :items => itemlist}}
	end	
end


def get_token
agent = login_action(params[:u],params[:pw])
test = agent.cookies.detect { |t| t.name == 'ses' }
	respond_to do |format|
		format.json { render :json =>{:session_token => test.value }}
	end	
end


def set_token(token)
	agent = Mechanize.new
	cookie = Mechanize::Cookie.new('ses', token)
	cookie.domain = "catalog.tadl.org"
	cookie.path = "/"
	agent.cookie_jar.add!(cookie)
	return agent
end


def get_user_with_token
	agent = set_token(params[:token])
	page = agent.get('http://catalog.tadl.org')
	doc = page.parser
	user_info = doc.css("body").map do |item| 
	{
	:name => item.at_css('#dash_user').try(:text).try(:strip),
	:checkouts => item.at_css('#dash_checked').try(:text).try(:strip),
	:holds => item.at_css('#dash_holds').try(:text).try(:strip),
	:pickups => item.at_css('#dash_pickup').try(:text).try(:strip),
	:fines => item.at_css('#dash_fines').try(:text).try(:strip),
	}
	end
	respond_to do |format|
		format.json { render :json =>{:user => user_info }}
	end	
end

def get_user_lists
	headers['Access-Control-Allow-Origin'] = "*"
	agent = set_token(params[:token])
	page = agent.get('https://catalog.tadl.org/eg/opac/myopac/lists')
	doc = page.parser
	lists = doc.css('.bookbag-controls-holder').map do |l|
		{
		:list_name => l.at_css('h2').text,
		:list_id => l.at_css('.bookbag-name').css('a').attr('href').text.split('?')[1].gsub('bbid=',''),
		}
	end
	offset = 0
	added_value = 10
	until doc.css('.invisible:contains("Next")').present? == true 
		offset = offset + added_value
		url = 'https://catalog.tadl.org/eg/opac/myopac/lists?loc=22;limit=10;offset=' + offset.to_s
		page = agent.get(url)
		doc = page.parser
		page_list = doc.css('.bookbag-controls-holder').map do |l|
			{
			:list_name => l.at_css('h2').text,
			:list_id => l.at_css('.bookbag-name').css('a').attr('href').text.split(';', 4)[3].gsub('bbid=',''),
			}
		end
		lists = lists + page_list
	end

	respond_to do |format|
		format.json { render :json =>{:lists => lists}}
	end	
end

def remove_from_list
	headers['Access-Control-Allow-Origin'] = "*"
	agent = set_token(params[:token])
	agent.get('https://catalog.tadl.org/eg/opac/myopac/lists?loc=22;')
	url = '/eg/opac/myopac/list/update?loc=22'
	agent.post(url, { 
		"bbid" => params[:list_id],
		"loc" => '22',
		"sort" => "",
		"list" => params[:list_id],
		"selected_item" => params[:list_item_id],
		"action" => params[:action],
	})
	respond_to do |format|
		format.json { render :json => 'done'}
	end	
end




def checkupdates
headers['Access-Control-Allow-Origin'] = "*"
@version_id = params[:version_id].to_i
@platform = params[:platform]
@android_current_version = 4
@ios_current_version = 0
@android_update = "https://play.google.com/store/apps/details?id=org.TADL.TADLMobile"
@ios_update = "https://itunes.apple.com/ua/app/tadl/id428802059"

if @platform === "ios"
@current_version = @ios_current_version
if @current_version <= @version_id
@message = "up to date client"
else
@message = "Updates Available"
end
end

if @platform === "android"
@current_version = @android_current_version
if @current_version <= @version_id
@message = "up to date client"
else
@message = "Updates Available"
end
end




respond_to do |format|

if @message === "up to date client"
format.json { render :json => { :message => @message}}
else
if @platform === "android"
format.json { render :json => { :message => @message, :update_link => @android_update}}
end
if @platform === "ios"
format.json { render :json => { :message => @message, :update_link => @ios_update}}

end
end



end





end

def passwordreset
  headers['Access-Control-Allow-Origin'] = "*"
  @user = params["user"]

  agent = Mechanize.new
  page = agent.get("https://catalog.tadl.org/eg/opac/password_reset")
  form = page.forms[1]

  if ( @user =~ /^TADL\d{7,8}$|^90\d{5}$|^91111\d{9}$|^[a-zA-Z]\d{10}/ )
    form.field_with(:name => "barcode").value = @user
  else
    form.field_with(:name => "username").value = @user
  end

  results = agent.submit(form)

  # TODO: check results and send appropriate status

  @response = { status: 'UNKNOWN' }

  respond_to do |format|
    format.json { render json: @response }
  end
end
  
end
