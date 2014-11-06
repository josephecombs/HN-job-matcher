require 'nokogiri'
#require 'net/http'
require 'open-uri'
require 'similar_text'


def scrape_file
  # some basics
  doc = Nokogiri::XML(File.open("shows.xml"))
  puts doc.css("sitcoms name") # css queries in xml!!!
  # puts doc.xpath("//character")
end

def scrape_site(url)
  #come back to this later
  doc = Nokogiri::HTML(open(url))  
  # puts doc.css('title')
  comments = doc.css('.comment')
  usernames = doc.css('.comhead > a').text
  puts comments.length
  #.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i)[0]
  usernames_comments = {}
  usernames_comments = hashify_comments(comments, usernames)
  usernames_comments
end

def hashify_comments(comments_arr, commentors_arr)
  usernames_comments = {}
  # turn off email matching for now
  # i = 0
  # comments_arr.each do |comment|
  #   if comment.to_s.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i)
  #     email_address = comment.to_s.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i)[0]
  #     emails_comments[email_address] = comment.text
  #   else
  #     email_address = "no_email_address_" + i.to_s
  #     emails_comments[email_address] = comment.text
  #     i += 1
  #   end
  # end
  
  comments_arr.each_with_index do |comment, idx|
    usernames_comments[commentors_arr[idx]] = comment 
  end
  
  #returns hash of usernames and comment
  usernames_comments
end

def test_regex
  #proves my regex works
  textblob = "aslkhalghakghaawghalga sfgaga asdg a !!! DFAsd fasdf joseph.e.combs@gmail.com slkerhg;ahg;gasngmgjhjdhhsdhls  hhj3548348 3452 3452 "
  if textblob.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i)
    email_address = textblob.match(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i)[0]
  end
  
  puts email_address
end



# hiring and seeking now in hashes where key is email address and value is comment
hiring = scrape_site("https://news.ycombinator.com/item?id=8542892")
seeking = scrape_site("https://news.ycombinator.com/item?id=8542898")

#for each person seeking a job, score their comment relative to each hiring post
# seeking.each_pair do |email_address, seeking_comment|
#   hiring.each_pair do |email_address, hiring_comment|
#     puts hiring_comment.similar(seeking_comment)
#   end
#   puts "analyzed one job seeker's post"
# end