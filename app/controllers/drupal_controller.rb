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
caches_action :drupal, :cache_path => Proc.new { |c| c.params }, :expires_in => 9.minutes, :race_condition_ttl => 1.minutes





def set_cache_headers
    headers['Access-Control-Allow-Origin'] = '*'      
end

def drupal
	if params[:content] 
		payload = Rails.cache.read(params[:content])
			respond_to do |format|
		format.json { render :json => payload }
	end
	else
		payload = Rails.cache.read('everything_else')
			respond_to do |format|
		format.json { render :json => payload }
	end
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

	payload = Rails.cache.read('library_reads')
	respond_to do |format|
		format.json { render :json => {:items => payload }}
	end

end


end