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




end
