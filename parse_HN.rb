require 'nokogiri'
require 'open-uri'
require 'similar_text'
require 'amatch'

def scrape_site(url)
  doc = Nokogiri::HTML(open(url))  
  comments = doc.css('.comment')
  usernames = doc.css('.comhead > a')
  # purify usernames a bit
  usernames = usernames.select.each_with_index { |str, i| i.even? }
  usernames.each_with_index do |username, idx|
    #TODO: parse this better
    new_idx = username.to_s[0..-1].index(">")
    usernames[idx] = username.to_s[17..(new_idx - 2)]
  end

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
    usernames_comments[commentors_arr[idx]] = comment.text
  end
  
  #returns hash of usernames and comment
  usernames_comments
end

# hiring and seeking now in hashes where key is username and value is comment
hiring = scrape_site("https://news.ycombinator.com/item?id=8542892")
seeking = scrape_site("https://news.ycombinator.com/item?id=8542898")

# for each person seeking a job, score their comment relative to each hiring post
seeking.each_pair do |seeker_username, seeking_comment|
  # keys are similarity, values are the person wanting hiring
  score_rank = {}
  hiring.each_pair do |hirer_username, hiring_comment|
    score = hiring_comment.levenshtein_similar(seeking_comment)
    score_rank[score] = hirer_username
  end
  
  #this will actually turn score_rank into an array
  score_rank = score_rank.sort
  score_rank = score_rank.reverse
  out_file = File.new("spit/" + seeker_username + ".txt", "w")
  
  score_rank.each do |pair|
    out_file.puts("hiring_manager: " + pair[1] + "; similarity_score: " + pair[0].to_s[0..6])
  end
  
  puts "analyzed one job seeker's post"
end