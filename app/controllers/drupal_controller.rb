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

caches_action :test, :race_condition_ttl => 2.minutes

def drupal
payload = Rails.cache.read('test')
respond_to do |format|
format.json { render :json => payload }
end
end



def test
headers['Access-Control-Allow-Origin'] = "*"
timestamp = Time.now.to_s
books_featured_fiction = JSON.parse(open("https://www.tadl.org/mobile/export/items/67/json").read)
books_featured_nonfiction = JSON.parse(open("https://www.tadl.org/mobile/export/items/68/json").read)
books_reviews = JSON.parse(open("https://www.tadl.org/export/reviews/Books/json").read)
books_adult_display = JSON.parse(open("https://www.tadl.org/mobile/export/items/45/all/json").read)
books_adult_clubkits = JSON.parse(open("https://www.tadl.org/mobile/export/items/224/all/json").read)
books_adult_business = JSON.parse(open("https://www.tadl.org/mobile/export/items/234/all/json").read)
music_new = JSON.parse(open("https://www.tadl.org/mobile/export/items/29/json").read)
music_hot = JSON.parse(open("https://www.tadl.org/mobile/export/items/31/json").read)
music_reviews = JSON.parse(open("https://www.tadl.org/export/reviews/Music/json").read)
music_links = JSON.parse(open("https://www.tadl.org/export/node/json/133").read)
videos_new = JSON.parse(open("https://www.tadl.org/mobile/export/items/32/json").read)
videos_hot = JSON.parse(open("https://www.tadl.org/mobile/export/items/34/json").read)
videos_tcff = JSON.parse(open("https://www.tadl.org/mobile/export/items/165/all/json").read)
videos_met = JSON.parse(open("https://www.tadl.org/mobile/export/items/286/all/json").read)
video_reviews = JSON.parse(open("https://www.tadl.org/export/reviews/Video/json").read)
online_mel = JSON.parse(open("https://www.tadl.org/export/node/json/3373").read)
online_resources = JSON.parse(open("https://www.tadl.org/export/node/json/3372").read)
online_legal = JSON.parse(open("https://www.tadl.org/export/node/json/25242").read)
online_ebooks = JSON.parse(open("https://www.tadl.org/export/node/json/14040").read)
youth_display = JSON.parse(open("https://www.tadl.org/mobile/export/items/47/all/json").read) 
youth_new_books = JSON.parse(open("https://www.tadl.org/mobile/export/items/52/json").read)
youth_reviews = JSON.parse(open("https://www.tadl.org/export/reviews/Youth/json").read)
youth_events = JSON.parse(open("https://www.tadl.org/mobile/export/events/formatted/json/27").read)
youth_resources = JSON.parse(open("https://www.tadl.org/export/node/json/647").read)
youth_award_winners = JSON.parse(open("https://www.tadl.org/export/node/json/644").read)
teens_new = JSON.parse(open("https://www.tadl.org/mobile/export/items/51/json").read)
teens_manga = JSON.parse(open("https://www.tadl.org/mobile/export/items/41/json").read)
teens_events = JSON.parse(open("https://www.tadl.org/mobile/export/events/formatted/json/28").read)
teens_reviews = JSON.parse(open("https://www.tadl.org/export/reviews/Teens/json").read)
teens_homework = JSON.parse(open("https://www.tadl.org/export/node/json/409").read)
teens_lists = JSON.parse(open("https://www.tadl.org/export/node/json/12784").read)

respond_to do |format|
format.json { render :json => { :time => timestamp, 
	:books_featured_fiction => books_featured_fiction, 
	:books_featured_nonfiction => books_featured_nonfiction, 
	:books_adult_display => books_adult_display,
	:books_adult_clubkits => books_adult_clubkits,
	:books_adult_business => books_adult_business,
	:books_reviews => books_reviews,
	:music_new => music_new, 
	:music_hot => music_hot,
	:muisc_reviews => music_reviews,
	:music_links => music_links,
	:videos_new => videos_new,
	:vdeos_hot => videos_hot,
	:videos_tcff => videos_tcff,
	:videos_met => videos_met,
	:video_reviews => video_reviews,
	:online_mel => online_mel,
	:online_resources => online_resources,
	:online_legal => online_legal,
	:online_ebooks => online_ebooks,
	:youth_display => youth_display, 
	:youth_new_books => youth_new_books,
	:youth_reviews => youth_reviews,
	:youth_events => youth_events,
	:youth_resources => youth_resources,
	:youth_award_winners => youth_award_winners,
	:teens_new => teens_new,
	:teens_manga => teens_manga,
	:teens_events => teens_events,
	:teens_reviews => teens_reviews,
	:teens_homework => teens_homework,
	:teens_lists => teens_lists,	
	:featured_news => featured_news,
	:music_hot => music_hot,

	}}
end

end



end
