desc "Get Lists from Drupal Feeds and Turn Them into Evergreen Lists"
task :drupal_to_list => :environment do
require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'oj'
require 'nikkou'
require 'dalli'
require 'memcachier'
require 'timeout'

username = ENV['evergreen_username']
password = ENV['evergreen_password']

urls_and_list_ids = [{"name" => "New Music", "url" => "https://www.tadl.org/mobile/export/items/29/json", "list_id" => "19036"},
	{"name" => "Hot Music", "url" => "https://www.tadl.org/mobile/export/items/31/json", "list_id" => "19038"},
	{"name" => "Featured Fiction", "url" => "https://www.tadl.org/mobile/export/items/67/json", "list_id" => "19039"},
	{"name" => "Featured Non-Fiction", "url" => "https://www.tadl.org/mobile/export/items/68/json", "list_id" => "19040"},
	{"name" => "Adult Display", "url" => "https://www.tadl.org/mobile/export/items/45/json/all.json", "list_id" => "19041"},
	{"name" => "Club Kits", "url" => "https://www.tadl.org/mobile/export/items/224/json", "list_id" => "19042"},
	{"name" => "Business Books", "url" => "https://www.tadl.org/mobile/export/items/234/json", "list_id" => "19043"},
	{"name" => "New Videos", "url" => "https://www.tadl.org/mobile/export/items/32/json", "list_id" => "19044"},
	{"name" => "Hot Videos", "url" => "https://www.tadl.org/mobile/export/items/34/json", "list_id" => "19045"},
	{"name" => "TCFF Films", "url" => "https://www.tadl.org/mobile/export/items/165/all.json", "list_id" => "19046"},
	{"name" => "Met Opera", "url" => "https://www.tadl.org/mobile/export/items/286/all.json", "list_id" => "19047"},
	{"name" => "Youth New", "url" => "https://www.tadl.org/mobile/export/items/52/json", "list_id" => "19048"},
	{"name" => "Youth Display", "url" => "https://www.tadl.org/mobile/export/items/47/json/all.json", "list_id" => "19049"},
	{"name" => "Teen New", "url" => "https://www.tadl.org/mobile/export/items/51/json", "list_id" => "19050"},
	{"name" => "Manga", "url" => "https://www.tadl.org/mobile/export/items/41/json", "list_id" => "19051"},
]

	urls_and_list_ids.each do |i|
		record_container = ''
		list_object = Dish(i)
		list_id = list_object.list_id
		name = list_object.name
		feed = JSON.parse(open(list_object.url).read)
		feed_object = Dish(feed['nodes'])
		feed_object.each do |f|
			record = f.node.item + ','
			record_container = record_container + record
		end
		record_container = record_container.sub!(/[,]?$/, '')
		url = 'https://mel-catcher.herokuapp.com/main/add_to_list.json?u='+ username +'&pw='+ password +'&list_id=' + list_id +'&record_ids='+ record_container
		agent = Mechanize.new
		page = agent.get(url)
		puts 'Finished loading ' + name
	end

end



