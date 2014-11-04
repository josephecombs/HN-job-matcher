require 'nokogiri'
#require 'net/http'
require 'open-uri'


def scrape_file
  doc = Nokogiri::XML(File.open("shows.xml"))
  puts doc.css("sitcoms name") # css queries in xml!!!
  # puts doc.xpath("//character")
end

def scrape_site
  #come back to this later
  doc = Nokogiri::HTML(open("http://www.threescompany.com/"))  
end

# scrape_file
scrape_site