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
require 'json'

before_filter :set_cache_headers, :only => [:drupal] 






def set_cache_headers
    headers['Access-Control-Allow-Origin'] = '*'      
end

def drupal
payload = Rails.cache.read('test')
respond_to do |format|
format.json { render :json => payload }
end
end

def ny_list
timestamp = Time.now.to_s
@combined_print_e_book_fiction = JSON.parse(open("http://api.nytimes.com/svc/books/v2/lists//combined-print-fiction.json?&offset=&sortby=&sortorder=&api-key=5129bf11004d0f645f4303c6390a3222:8:68605282").read)



k = 'isbn10'



@cat = @combined_print_e_book_fiction["results"].map do |x|
{
:rank => x["rank"],
:isbns => x["isbns"]
}
end

@bird = []
@cat.each do |z|
snake = z[:isbns]
penny = z[:rank].to_s
isbn = []
snake.each do |q|
rabbit = q["isbn13"].to_s
isbn.push([rabbit]) 
end
@bird.push({:rank=> penny,:isbn=> isbn})
end

@donkey = []
@bird.each do |x|

my_isbns = ""

x[:isbn].each do |w|

my_isbns = my_isbns + w.to_s

end
@donkey.push(my_isbns)
end

respond_to do |format|
format.json { render :json => {:booklist => @bird }}
end






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