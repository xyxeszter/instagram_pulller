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
				#url_list << img_source.split('\n')
				url_list << img_source
		end
	end
	#3. read from cvs file
	tmp_list = []
	CSV.foreach('database.csv') do |row|
  		#4. compare, look for and store new entity
  		puts row
  		if not url_list.include?(row)
  			tmp_list << row
  			puts "new entity: "
  			puts row
  		end
	end

	#5. write new entity for cvs
	if not tmp_list.empty?
		puts "now: #{tmp_list}" 
		CSV.open('database.csv', 'wb') do |csv|
			tmp_list.each do |el| 
				csv << el
			end
			# csv << tmp_list.split("\n")
		end
	end
				#	

end
#6. schedule, close
scheduler.join
