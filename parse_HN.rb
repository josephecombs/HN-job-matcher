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
  doc = Nokogiri::HTML(open("https://news.ycombinator.com/item?id=8542892"))  
  # puts doc.css('title')
  comments = doc.css('.comment')
  puts comments.length
  #.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i)[0]
  emails_comments = {}
  emails_comments = hashify_emails(comments)
  puts emails_comments.keys
end

def hashify_emails(comments_arr)
  emails_comments = {}
  
  comments_arr.each do |comment|
    if comment.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i)[0]
      email_address = comment.match
    end
  end
  
  emails_comments
end

def test_regex
  
end



# scrape_file
scrape_site