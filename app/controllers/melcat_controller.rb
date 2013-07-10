class MelcatController < ApplicationController
respond_to :html, :json
require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'oj'
require 'nikkou'

def searchmelcat

if params[:q].present?
@searchquery = params[:q]
@searchqueryclearned = CGI::escape(@searchquery)    
else
@searchqueryclearned = ""       
end    

@pagetitle = 'http://elibrary.mel.org/search/a?searchtype=X&searcharg=' + @searchqueryclearned + '&SORT=D' 
url = @pagetitle
@doc = Nokogiri::HTML(open(url))
@itemlist = @doc.search('tr').text_includes("ISBN/ISSN:").map do |item|
{
item:
{
:title => item.at_css('.briefcitTitle').try(:text).try(:strip),
:author => item.css('td[4]/br')[1].previous.try(:text).try(:strip),
:p_description => item.css('td[4]/br')[1].next.try(:text).try(:strip),
:isbn => item.css('td[4]/br')[2].next.try(:text).try(:strip).gsub(/[^0-9]/, ""),
:melcat_id => item.at_css('td[1]/input')['value']
}
}
end 

@test = @pagetitle

respond_to do |format|
format.json { render :json => Oj.dump(items: @itemlist.uniq)  }
end


end


def showmelcat


@record_id = params[:record_id]
  

@pagetitle = 'http://elibrary.mel.org/record=' + @record_id 
url = @pagetitle
@doc = Nokogiri::HTML(open(url))

if @doc.css('//table.centralHoldingsTable//tr').present?
@shelvinglocations = @doc.css('//table.centralHoldingsTable//tr')[1..-1].map do |detail|
if detail.at_css("td[5]").try(:text).try(:squeeze, " ") == "AVAILABLE" 
{
shelf_location:
{
:library => detail.at_css("td[1]").try(:text).try(:squeeze, " "),
:shelving_location => detail.at_css("td[2]").try(:text).try(:squeeze, " "),
:call_number => detail.at_css("td[4]").try(:text).try(:squeeze, " "),
:available => detail.at_css("td[5]").try(:text).try(:squeeze, " "),
}
}
end
end
@shelvinglocations_filtered = @shelvinglocations.compact.uniq
end


@test = @pagetitle

respond_to do |format|
format.json { render :json => Oj.dump(items: @shelvinglocations_filtered)  }
end











end
end