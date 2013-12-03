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
caches_action :test, :expires_in => 5.minutes

def test
headers['Access-Control-Allow-Origin'] = "*"
timestamp = Time.now.to_s
featured_fiction = JSON.parse(open("https://www.tadl.org/mobile/export/items/67/json").read)
featured_nonfiction = JSON.parse(open("https://www.tadl.org/mobile/export/items/68/json").read)
new_music = JSON.parse(open("https://www.tadl.org/mobile/export/items/29/json").read)
featured_news = JSON.parse(open("https://www.tadl.org/export/news/json").read)
events = JSON.parse(open("https://www.tadl.org/mobile/export/events/formatted/json/all").read)
respond_to do |format|
format.json { render :json => { :time => timestamp, 
	:featured_fiction => featured_fiction, 
	:featured_nonfiction => featured_nonfiction, 
	:new_music => new_music, 
	:featured_news => featured_news,
	:events => events,
	}}
end

end










end
