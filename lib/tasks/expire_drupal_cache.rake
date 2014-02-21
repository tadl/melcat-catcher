desc "Expire and regenerate cache"
task :recreate => :environment do
require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'oj'
require 'nikkou'
require 'dalli'
require 'memcachier'
require 'timeout'


timestamp = Time.now.to_s
adult_events = JSON.parse(open("https://www.tadl.org/mobile/export/events/formatted/json/26").read)
books_featured_fiction = JSON.parse(open("https://www.tadl.org/mobile/export/items/67/json").read)
books_featured_nonfiction = JSON.parse(open("https://www.tadl.org/mobile/export/items/68/json").read)
books_reviews = JSON.parse(open("https://www.tadl.org/export/reviews/Books/json").read)
books_adult_display = JSON.parse(open("https://www.tadl.org/mobile/export/items/45/all/json").read)
books_adult_clubkits = JSON.parse(open("https://www.tadl.org/mobile/export/items/224/all/json").read)
books_adult_business = JSON.parse(open("https://www.tadl.org/mobile/export/items/234/all/json").read)
books_book_list = JSON.parse(open("https://www.tadl.org/export/node/json/80").read)
music_new = JSON.parse(open("https://www.tadl.org/mobile/export/items/29/json").read)
music_hot = JSON.parse(open("https://www.tadl.org/mobile/export/items/31/json").read)
music_reviews = JSON.parse(open("https://www.tadl.org/export/reviews/Music/json").read)
music_links = JSON.parse(open("https://www.tadl.org/export/node/json/113").read)
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
hours_pcl = JSON.parse(open("https://www.tadl.org/mobile/export/locations/pcl").read)
hours_ebb = JSON.parse(open("https://www.tadl.org/mobile/export/locations/ebb").read)
hours_kbl = JSON.parse(open("https://www.tadl.org/mobile/export/locations/kbl").read)
hours_ipl = JSON.parse(open("https://www.tadl.org/mobile/export/locations/ipl").read)
hours_flpl = JSON.parse(open("https://www.tadl.org/mobile/export/locations/flpl").read)
hours_wood = JSON.parse(open("https://www.tadl.org/mobile/export/locations/wood").read)
infobox_pcl = JSON.parse(open("https://www.tadl.org/export/node/json/583").read)
infobox_ebb = JSON.parse(open("https://www.tadl.org/export/node/json/5439").read)
infobox_kbl = JSON.parse(open("https://www.tadl.org/export/node/json/23123").read)
infobox_ipl = JSON.parse(open("https://www.tadl.org/export/node/json/580").read)
infobox_flpl = JSON.parse(open("https://www.tadl.org/export/node/json/578").read)
infobox_wood = JSON.parse(open("https://www.tadl.org/export/node/json/5439").read)
featured_news = JSON.parse(open("https://www.tadl.org/export/news/json").read)
events = JSON.parse(open("https://www.tadl.org/mobile/export/events/formatted/json/all").read)
events_pcl = JSON.parse(open("https://www.tadl.org/mobile/export/events/formatted/json/24").read)
events_ebb = JSON.parse(open("https://www.tadl.org/mobile/export/events/formatted/json/19").read)
events_kbl = JSON.parse(open("https://www.tadl.org/mobile/export/events/formatted/json/22").read)
events_ipl = JSON.parse(open("https://www.tadl.org/mobile/export/events/formatted/json/21").read)
events_flpl = JSON.parse(open("https://www.tadl.org/mobile/export/events/formatted/json/20").read)
events_wood = JSON.parse(open("https://www.tadl.org/mobile/export/events/formatted/json/25").read)
news_pcl = JSON.parse(open("https://www.tadl.org/export/news/location/json/24").read) 
news_ebb = JSON.parse(open("https://www.tadl.org/export/news/location/json/19").read) 
news_kbl = JSON.parse(open("https://www.tadl.org/export/news/location/json/22").read) 
news_ipl = JSON.parse(open("https://www.tadl.org/export/news/location/json/21").read) 
news_flpl = JSON.parse(open("https://www.tadl.org/export/news/location/json/20").read) 
news_wood = JSON.parse(open("https://www.tadl.org/export/news/location/json/25").read) 

home = {
	:featured_news => featured_news,
	:events => events,
	:books_featured_fiction => books_featured_fiction, 
	:books_featured_nonfiction => books_featured_nonfiction,
	:videos_new => videos_new,
	:music_new => music_new,
	:hours_ebb => hours_ebb,
	:hours_pcl => hours_pcl,
	:hours_kbl => hours_kbl,
	:hours_ipl => hours_ipl,
	:hours_flpl => hours_flpl,
	:hours_wood => hours_wood,
}

books = {
	:books_featured_fiction => books_featured_fiction, 
	:books_featured_nonfiction => books_featured_nonfiction, 
	:books_adult_display => books_adult_display,
	:books_adult_clubkits => books_adult_clubkits,
	:books_adult_business => books_adult_business,
	:books_reviews => books_reviews,
	:books_book_list => books_book_list,  
}

music = {
	:music_new => music_new, 
	:music_hot => music_hot,
	:music_reviews => music_reviews,
	:music_links => music_links,
}

videos = {
	:videos_new => videos_new,
	:videos_hot => videos_hot,
	:videos_tcff => videos_tcff,
	:videos_met => videos_met,
	:videos_reviews => video_reviews,
}

online = {
	:online_mel => online_mel,
	:online_resources => online_resources,
	:online_legal => online_legal,
	:online_ebooks => online_ebooks,
}

youth = {
	:youth_display => youth_display, 
	:youth_new_books => youth_new_books,
	:youth_reviews => youth_reviews,
	:events_youth => youth_events,
	:youth_resources => youth_resources,
	:youth_award_winners => youth_award_winners,
}

teens = {
	:teens_new => teens_new,
	:teens_manga => teens_manga,
	:events_teens => teens_events,
	:teens_reviews => teens_reviews,
	:teens_homework => teens_homework,
	:teens_lists => teens_lists,
}

lists = {
	:teens_new => teens_new,
	:teens_manga => teens_manga,
	:youth_display => youth_display, 
	:youth_new_books => youth_new_books,
	:videos_new => videos_new,
	:videos_hot => videos_hot,
	:videos_tcff => videos_tcff,
	:videos_met => videos_met,
	:music_new => music_new, 
	:music_hot => music_hot,
	:books_featured_fiction => books_featured_fiction, 
	:books_featured_nonfiction => books_featured_nonfiction, 
	:books_adult_display => books_adult_display,
	:books_adult_clubkits => books_adult_clubkits,
	:books_adult_business => books_adult_business,
}

locations = {
	:hours_ebb => hours_ebb,
	:hours_pcl => hours_pcl,
	:hours_kbl => hours_kbl,
	:hours_ipl => hours_ipl,
	:hours_flpl => hours_flpl,
	:hours_wood => hours_wood,
	:infobox_pcl => infobox_pcl,
	:infobox_ebb => infobox_ebb,
	:infobox_kbl => infobox_kbl,
	:infobox_ipl => infobox_ipl,
	:infobox_flpl => infobox_flpl,
	:infobox_wood => infobox_wood,
	:events_pcl => events_pcl,
	:events_ebb => events_ebb,
	:events_kbl => events_kbl,
	:events_ipl => events_ipl,
	:events_flpl => events_flpl,
	:events_wood => events_wood,
	:news_pcl => news_pcl,
	:news_ebb => news_ebb,
	:news_kbl => news_kbl,
	:news_ipl => news_ipl,
	:news_flpl => news_flpl,
	:news_wood => news_wood,
}


everything_else = { :time => timestamp,
	:events_adults => adult_events,
	:books_featured_fiction => books_featured_fiction, 
	:books_featured_nonfiction => books_featured_nonfiction, 
	:books_adult_display => books_adult_display,
	:books_adult_clubkits => books_adult_clubkits,
	:books_adult_business => books_adult_business,
	:books_reviews => books_reviews,
	:books_book_list => books_book_list,  
	:music_new => music_new, 
	:music_hot => music_hot,
	:music_reviews => music_reviews,
	:music_links => music_links,
	:videos_new => videos_new,
	:videos_hot => videos_hot,
	:videos_tcff => videos_tcff,
	:videos_met => videos_met,
	:videos_reviews => video_reviews,
	:online_mel => online_mel,
	:online_resources => online_resources,
	:online_legal => online_legal,
	:online_ebooks => online_ebooks,
	:youth_display => youth_display, 
	:youth_new_books => youth_new_books,
	:youth_reviews => youth_reviews,
	:events_youth => youth_events,
	:youth_resources => youth_resources,
	:youth_award_winners => youth_award_winners,
	:teens_new => teens_new,
	:teens_manga => teens_manga,
	:events_teens => teens_events,
	:teens_reviews => teens_reviews,
	:teens_homework => teens_homework,
	:teens_lists => teens_lists,	
	:featured_news => featured_news,
	:events => events,
	:hours_ebb => hours_ebb,
	:hours_pcl => hours_pcl,
	:hours_kbl => hours_kbl,
	:hours_ipl => hours_ipl,
	:hours_flpl => hours_flpl,
	:hours_wood => hours_wood,
	:infobox_pcl => infobox_pcl,
	:infobox_ebb => infobox_ebb,
	:infobox_kbl => infobox_kbl,
	:infobox_ipl => infobox_ipl,
	:infobox_flpl => infobox_flpl,
	:infobox_wood => infobox_wood,
	:events_pcl => events_pcl,
	:events_ebb => events_ebb,
	:events_kbl => events_kbl,
	:events_ipl => events_ipl,
	:events_flpl => events_flpl,
	:events_wood => events_wood,
	:news_pcl => news_pcl,
	:news_ebb => news_ebb,
	:news_kbl => news_kbl,
	:news_ipl => news_ipl,
	:news_flpl => news_flpl,
	:news_wood => news_wood,
	}


Rails.cache.write("everything_else", everything_else)
Rails.cache.write("home", home)
Rails.cache.write("books", books)
Rails.cache.write("music", music)
Rails.cache.write("video", videos)
Rails.cache.write("youth", youth)
Rails.cache.write("teens", teens)
Rails.cache.write("online", online)
Rails.cache.write("lists", lists)
Rails.cache.write("locations", locations)



end
