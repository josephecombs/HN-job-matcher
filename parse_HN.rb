require 'nokogiri'
require 'open-uri'
require 'similar_text'
require 'amatch'

def scrape_site(url)
  doc = Nokogiri::HTML(open(url))  
  #TODO: need to figure out how to select exactly parent comments
  # the issue is that replies are being treated as relevant
  
  # 'images' array will be used to determine whether or not a comment is a parent comment
  images_length = doc.css('img').length
  
  # images will have 2 extraneous images at the start and 2 extraneous images at the end
  images = doc.css('img')[2..(images_length - 2)]
  comments = doc.css('.comment')
  
  
  puts images.length
  puts comments.length
  
  # puts images.first
  # puts comments.first
  
  puts images.last
  puts comments.last
  
  sleep(100)
  # 
  usernames = doc.css('.comhead > a')
  # purify usernames a bit
  usernames = usernames.select.each_with_index { |str, i| i.even? }
  usernames.each_with_index do |username, idx|
    #TODO: parse this better
    new_idx = username.to_s[0..-1].index(">")
    usernames[idx] = username.to_s[17..(new_idx - 2)]
  end

  hashify_comments(comments, usernames, images)
end

def hashify_comments(comments_arr, commentors_arr, images_arr)
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
    #check if the comment is a parent comment; width of corresponding image determines whether a comment is one we care about or not, specifically a width of zero
    if images_arr[idx].attributes['width'].value == 0
      usernames_comments[commentors_arr[idx]] = dump_to_array(comment.text)
    end
  end
  
  #returns hash of usernames and comment text
  usernames_comments
end

def dump_to_array(str)
  #strip out irrelevant characters
  temp_str = str.gsub(/[^a-zA-Z0-9 ]/,"")
  words_array = temp_str.split(" ")
  words_array = words_array.map(&:downcase).uniq
  words_array
end

# this computes the percentage of 
def jec_compare(arr1, arr2)
  temp_denom = (arr1 + arr2).uniq
  #calculates the percentage to which arr1's words covers the universe of words
  #this is bad because it will match you to short comments; need to figure out how to select only parent comments with nokogiri
  (arr1.length)/(temp_denom.length * 1.0)
end

# hiring and seeking now in hashes where key is username and value is array of words in comment
hiring = scrape_site("https://news.ycombinator.com/item?id=8542892")
seeking = scrape_site("https://news.ycombinator.com/item?id=8542898")

# for each person seeking a job, score their comment relative to each hiring post
seeking.each_pair do |seeker_username, seeking_comment|
  i = 0
  score_rank = {}
  hiring.each_pair do |hirer_username, hiring_comment|
    
    score = jec_compare(seeking_comment, hiring_comment)
    #introduce randomness because I think some results are being overwritten
    score = score - (Random.rand(0..1000) / 100000000.0)
    i += 1
    score_rank[score] = hirer_username
  end
  
  puts i
  #this will actually turn score_rank into an array
  score_rank = score_rank.sort
  score_rank = score_rank.reverse
  
  out_file = File.new("spit/" + seeker_username + ".txt", "w")
  
  score_rank.each do |pair|
    out_file.puts("hiring_manager: " + pair[1] + "; similarity_score: " + pair[0].to_s[0..6])
  end
  
  puts "analyzed one job seeker's post"
end