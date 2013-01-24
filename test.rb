require 'rubygems'
require 'net/http'
require 'open-uri'
require 'nokogiri'


doc = Nokogiri::HTML(open('http://statigr.am/tag/theboscoboyz'))


doc.css("//div[@id='listeLiensPhotos']").css("a").each do |link|
	
	if link.to_s.include?('/p/') and !link.to_s.include?('http')
		
		#puts link.first
		sublink = 'http://statigr.am/' + link.first.to_s
		subdoc = Nokogiri::HTML(open(sublink))
			
			img_source = subdoc.css("meta[@property='og:image']/@content").to_s.gsub("_5", "_7")
				
			
			puts img_source
	end
end

