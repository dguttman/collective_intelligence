load 'delicious.rb'
load 'recommendations.rb'


class DeliciousRecommender
	
	attr_reader :users

	def initialize(tag, count=5, user)
		@users = Hash.new {|h, k| h[k] = {}}
		@delicious = DeliciousFeedReader.new

		@delicious.get_popular(tag)[0..count].each do |post|
			@delicious.get_url(post).each { |posting|	@users[posting['user']] = {}}
		end
		@users[user] = {}		
	  fill_items
	end

	def top_matches(user)
		puts super(@users, user)
	end

	def recommendations(user, n=10)
		puts super(@users, user)[0..10]
	end

	def similar_to(link)
		@transformed ||= transform_hash(@users)
		top_matches(@transformed, link)
	end

	private

	def fill_items
		all_items = {}	

		@users.each do |user, ratings|
			@delicious.get_user(user).each do |post|
				@users[user][post['u']] = 1.0
				all_items[post['u']] = 1
			end
		end

		 @users.each do |user, ratings|
		 	all_items.each do |item, n|
		 		ratings[item] = 0.0 unless ratings.include?(item)
		 	end
		 end
	end

end

@d = DeliciousRecommender.new("Ruby", 5, 'momoro')
