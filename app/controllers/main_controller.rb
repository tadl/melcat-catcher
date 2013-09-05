class MainController < ApplicationController
respond_to :html, :json
require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'oj'
require 'nikkou'

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
    elsif params[:mt] == "ALL FORMATS"
    @mediatype = "format="
    @fdefault = "ALL" 
    end
    else 
    @mediatype = "format="
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
:record_id => item.at_css(".search_link").attr('name').sub!(/record_/, ""),
:image => item.at_css(".result_table_pic").try(:attr, "src").try(:gsub, /^\//, "http://catalog.tadl.org/"),
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



if @itemlist.count == 0

respond_to do |format|
format.json { render :json => { :status => :error, :message => "no results" }}
end


else

respond_to do |format|
format.json { render :json => {:items => @itemlist, :subjects => @subjectlist, :selected => @selectedfacets }}
end

end
end

def itemdetails
headers['Access-Control-Allow-Origin'] = "*"
@gottem = "gottem"
@nope = "nope"
@record_id = params[:record_id]
@pagetitle = 'http://catalog.tadl.org/eg/opac/record/' + @record_id + '?locg=22;copy_offset=0;copy_limit=75'
url = @pagetitle
@doc = Nokogiri::HTML(open(url)) 
@record_details = @doc.css("#main-content").map do |detail|
{
item:
{
:author => detail.at_css(".rdetail_authors_div").try(:text).try(:gsub!, /\n/," ").try(:squeeze, " "),
:title => detail.at_css("#rdetail_title").text,
:summary => detail.at_css("#rdetail_summary_from_rec").try(:text).try(:strip),
:record_id => @record_id,
:copies_available => detail.at_css(".rdetail_aux_copycounts").try(:text).try(:strip).try(:gsub!, /available in District./," ").try(:squeeze, " ").try(:strip),
:copies_total => detail.at_css(".rdetail_aux_holdcounts").try(:text).try(:strip).try(:split, "on ").try(:last).try(:gsub, /copies./," ").try(:gsub, /copy./," ").try(:strip),
:eresource => detail.at_css('/div[2]/p/a').try(:attr, "href"),
:image => detail.at_css('#rdetail_image').try(:attr, "src").try(:gsub, /^\//, "http://catalog.tadl.org/"),
:format_icon => detail.at_css('.format_icon/img').try(:attr, "src").try(:gsub, /^\//, "http://catalog.tadl.org/"),
:record_year => detail.search('span[@itemprop="datePublished"]').try(:text),
}
}
end

if @doc.css('//table#rdetails_status//tr').present?
@shelvinglocations = @doc.css('//table#rdetails_status//tr')[1..-1].map do |detail|
if detail.at_css("td[4]").try(:text).try(:squeeze, " ") == "Available" || detail.at_css("td[4]").try(:text).try(:squeeze, " ") == "Reshelving"
{
shelf_location:
{
:library => detail.at_css("td[1]").try(:text).try(:squeeze, " "),
:shelving_location => detail.at_css("td[3]").try(:text).try(:squeeze, " "),
:call_number => detail.at_css("td[2]").try(:text).try(:squeeze, " "),
:available => detail.at_css("td[4]").try(:text).try(:squeeze, " "),
}
}
end
end
@shelvinglocations_filtered = @shelvinglocations.compact.uniq
end

respond_to do |format|
format.json { render :json => Oj.dump(items: @record_details, shelvinglocations: @shelvinglocations_filtered)  }
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
@username = params[:u]
@password = params[:pw]
agent = Mechanize.new
page = agent.get("https://catalog.tadl.org/eg/opac/login?redirect_to=%2Feg%2Fopac%2Fmyopac%2Fmain")
page.forms.class == Array
form = agent.page.forms[1]
form.field_with(:name => "username").value = @username
form.field_with(:name => "password").value = @password
results = agent.submit(form)
accountpage = agent.get("https://catalog.tadl.org/eg/opac/myopac/main")
@doc = accountpage.parser

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

if @user.count == 0 || @user[0][:user][:name] == nil

respond_to do |format|
format.json { render :json => { :status => :error, :message => "Bad Login or Password" }}
end
else

respond_to do |format|
format.json { render :json => Oj.dump(users: @user)  }
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


  
end
