#1. schedule, start
#2. load data
#3. read from cvs file
#4. compare, look for new entity
#5. write new entity for cvs
#6. schedule, close


#!/usr/bin/ruby

require 'rubygems'
require 'net/http'
require 'open-uri'
require 'nokogiri'
require 'rufus/scheduler'
require 'csv'

myUrl = 'http://statigr.am/tag/theboscoboyz'

scheduler = Rufus::Scheduler.start_new

#1, start scheduler 
scheduler.every '10s' do

	url_list = []
	#LOAD DATA FROM URL
	puts Time.now.strftime("%I:%M:%S")

	doc = Nokogiri::HTML(open(myUrl))
	doc.css("//div[@id='listeLiensPhotos']").css("a").each do |link|
		if link.to_s.include?('/p/') and !link.to_s.include?('http')
			sublink = 'http://statigr.am/' + link.first.to_s
			subdoc = Nokogiri::HTML(open(sublink))
				img_source = subdoc.css("meta[@property='og:image']/@content").to_s.gsub("_5", "_7")
				#loaded URLs
				url_list << img_source.to_s
				url_list << "\n"
				#url_list << img_source
		end
	end
	puts "url_list: #{url_list}"
	#3. read from cvs file
	tmp_list = []
	tmp_database = []

	# 4 read all the cvs to an array
	# go through url links each and check if its in cvs
	CSV.foreach('database.csv') do |row|
		tmp_database << row
		tmp_database << "\n"
	end
	puts "tmp_database : #{tmp_database}"
	
	url_list.each do |uri|
		unless tmp_database.include?(uri)
			tmp_list << uri
			puts "uri added: #{uri}"
		end
	end

	#5. write new entity for cvs
	unless tmp_list.empty?
		puts "tmp_list: #{tmp_list}" 
		CSV.open('database.csv', 'wb') do |csv|
			tmp_list.each do |el| 
				puts "writing row: #{el}"
				csv << [el.to_s]
			end
			# csv << tmp_list.split("\n")
		end
	end
				#	

end
#6. schedule, close
scheduler.join
