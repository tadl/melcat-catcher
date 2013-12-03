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
caches_action :test

def test
headers['Access-Control-Allow-Origin'] = "*"
featured_fiction = JSON.parse(open("https://www.tadl.org/mobile/export/items/67/json").read)
featured_nonfiction = JSON.parse(open("https://www.tadl.org/mobile/export/items/68/json").read)
respond_to do |format|
format.json { render :json => { :featured_fiction => featured_fiction, :featured_nonfiction => featured_nonfiction }}
end

end










end
