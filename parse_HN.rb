require 'nokogiri'
#require 'net/http'

def scrape
  doc = Nokogiri::XML(File.open("shows.xml"))
  puts doc.css("sitcoms name") # css queries in xml!!!
  puts doc.xpath("//character")
end

scrape