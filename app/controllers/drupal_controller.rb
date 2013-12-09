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

caches_action :drupal, :expires_in => 9.minutes, :race_condition_ttl => 1.minutes

def drupal
headers['Access-Control-Allow-Origin'] = '*'
headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
headers['Access-Control-Request-Method'] = '*'
headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
payload = Rails.cache.read('test')
respond_to do |format|
format.json { render :json => payload }
end
end





end
