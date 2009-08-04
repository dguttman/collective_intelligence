require 'rubygems'
require 'rfeedparser'

class FeedVectorGenerator

  @@min_word_freq = 0.1
  @@max_word_freq = 0.5

  # Returns title and dictionary of word counts for an RSS feed
  def self.get_word_counts(url)
    # Parse the feed
    begin
      doc = FeedParser.parse(url)
    rescue Timeout::Error
      p "Error: #{url}"
      return
    end
    word_counts = {}
  
    # Loop over all the entries
    doc.entries.each do |entry|
      if entry.summary
        summary = entry.summary
      else
        summary = entry.description
      end
    
      # Extract a list of words
      words = self.get_words(entry.title + ' ' + summary)
      words.each do |word|
        word_counts[word] ||= 0
        word_counts[word] += 1
      end
    
    end
    p "Parsed: #{doc.feed.title}"
    return [doc.feed.title, word_counts]
  end

  def self.get_words(html)
    # Remove all the HTML tags
    txt = html.gsub(/<[^>]+>/, '')
  
    # Split words by all non-alpha characters
    words = txt.split(/[^A-Z^a-z]+/)
  
    # Convert to lowercase
    words.map! {|w| w.downcase}
  
    return words
  end
  
  def self.create_matrix(feedlist, outfile)
    
    appear_count = {}
    word_counts = {}
    
    feedlist = [feedlist] unless feedlist.class == Array
    feedlist.each do |feed_url|
      blog_title, blog_word_count = self.get_word_counts(feed_url)
      next if blog_title == nil || blog_word_count == nil
      word_counts[blog_title] = blog_word_count
      blog_word_count.each do |word, count|
        appear_count[word] ||= 0
        appear_count[word] += 1
      end
    end
    
    word_list = []
    appear_count.each do |word, count|
      frac = count.to_f / feedlist.size
      if frac > @@min_word_freq and frac < @@max_word_freq
        word_list << word
      end
    end
    
    out = File.new("#{outfile}.txt", "w")
    out << "Blog"
    word_list.each do |word|
      out << "\t #{word}"
    end
    out << "\n"
    word_counts.each do |blog, blog_word_count|
      out << "#{blog}"
      word_list.each do |word|
        if blog_word_count.keys.include? word
          out << "\t #{blog_word_count[word]}"
        else
          out << "\t 0"
        end
      end
      out << "\n"
    end
    out.close
  end
  
end