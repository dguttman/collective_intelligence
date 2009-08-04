require 'rmend'

require '2/delicious'



def dfr(tag, count, user)
	@users = Hash.new {|h, k| h[k] = {}}
	@delicious = DeliciousFeedReader.new

	@delicious.get_popular(tag)[0..count].each do |post|
		p "post: #{post} -- TRACE:delicious-test.rb:"
	end
	@users[user] = {}		

end

def fill_items
	@all_items = {}	

	@users.each do |user, ratings|
		@delicious.get_user(user).each do |post|
			@users[user][post['u']] = 1.0
			@all_items[post['u']] = 1
		end
	end

  @users.each do |user, ratings|
    @all_items.each do |item, n|
	 	  ratings[item] = 0.0 unless ratings.include?(item)
	 	end
  end
end

dfr("Ruby", 5, 'momoro')