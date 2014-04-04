desc "Expire and regenerate cache"
task :library_reads => :environment do
require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'oj'
require 'nikkou'
require 'dalli'
require 'memcachier'
require 'timeout'

def new_agent(url)
    agent = Mechanize.new
    page = agent.get(url)
    html = page.parser
    return html
end  

feed_url = 'http://libraryreads.org/'
		html = new_agent(feed_url)
		items = html.css('p:contains("ISBN")').map do |item|
			{
				:title => item.previous.previous.previous.previous.try(:text),
 				:author => item.previous.previous.try(:text),
 				:isbn => item.try(:text).split("ISBN:")[1].try(:strip),
 				:review => item.next.next.try(:text),
 				:review_author => item.next.next.next.next.try(:text),
			}
		end
		items.reverse_each do |item|
			puts item[:isbn]
			item_url = 'http://catalog.tadl.org/eg/opac/results?query=' + item[:isbn]
			html = new_agent(item_url)
			if html.search('p:contains("Keyword Search Tips")').present?
				items.delete(item)
			else
				holdings = html.css(".result_table_row").map do |item| 
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
        		:format_icon => item.at_css(".result_table_title_cell img").try(:attr, "src").try(:gsub, /^\//, "http://catalog.tadl.org/"),
      		}
    		end	
    		item.merge! :holdings => holdings
			end
		end
	

Rails.cache.write("library_reads", items)






end
