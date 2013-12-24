class DrupalController < ApplicationController
respond_to :html, :json
require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'oj'
require 'nikkou'
require 'dalli'
require 'memcachier'
require 'timeout'

before_filter :set_cache_headers, :only => [:drupal] 
caches_action :drupal, :expires_in => 9.minutes, :race_condition_ttl => 1.minutes

def drupal
payload = Rails.cache.read('test')
respond_to do |format|
format.json { render :json => payload }
end
end


def set_cache_headers
    headers['Access-Control-Allow-Origin'] = '*'      
end

def library_reads
agent = Mechanize.new
page = agent.get("http://libraryreads.org/")
@doc = page.parser

@booklist = @doc.css('p:contains("ISBN")').map do |item| 

{
:title => item.previous.previous.previous.previous.try(:text),
:author => item.previous.previous.try(:text),
:isbn => item.try(:text).split("ISBN:")[1].try(:strip),
:review => item.next.next.try(:text),
:review_author => item.next.next.next.next.try(:text)
}

end


@bad_isbns = []
@booklist.each do |item| 
url = "http://catalog.tadl.org/eg/opac/results?contains=contains&_special=1&loc=22&qtype=identifier%7Cisbn&query=" + item[:isbn]
page = Nokogiri::HTML(open(url))
if page.search('p:contains("Keyword Search Tips")').present?
@booklist.delete(item)

end
end
@booklist.each do |item|
url = "http://catalog.tadl.org/eg/opac/results?contains=contains&_special=1&loc=22&qtype=identifier%7Cisbn&query=" + item[:isbn]
page = Nokogiri::HTML(open(url))
@itemlist = page.css(".result_table_row").map do |thing| 
{
item:
{
:title => thing.at_css(".bigger").text.strip, 
:author => thing.at_css('[@name="item_author"]').text.strip.try(:squeeze, " "),
:availability => thing.at_css(".result_count").try(:text).try(:strip).try(:gsub!, /in TADL district./," "), 
:online => thing.search('a').text_includes("Connect to this resource online").first.try(:attr, "href"),
:record_id => thing.at_css(".search_link").attr('name').sub!(/record_/, ""),
:image => thing.at_css(".result_table_pic").try(:attr, "src").try(:gsub, /^\//, "http://catalog.tadl.org/"),
:abstract => thing.at_css(".result_table_summary").text.strip.try(:squeeze, " "),
:record_year => thing.at_css(".record_year").try(:text),
:format_icon => thing.at_css(".result_table_title_cell img").try(:attr, "src").try(:gsub, /^\//, "http://catalog.tadl.org/")
}
}
end

item.merge!(:items => @itemlist)
end



@tadl_has = @booklist2




respond_to do |format|
format.json { render :json => {:booklist => @booklist }}
end



end
end