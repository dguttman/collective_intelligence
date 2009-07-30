require 'rmend'

describe Rmend do 
  before do
    @users = %w(alice bob charlie david edgar frank george howard ishmael kelly lisa mary nancy oliver pat)
    
    @merchants = %w(apple bestbuy cadillac dunkindonuts ecco frog guess hardrock)
    
    @users_ratings = {}
    @users.each do |user|
      n = rand(@merchants.size - 3) + 1 + 3
      m = @merchants.dup
      @users_ratings[user] = {}
      (1..n).each do |i|
        @users_ratings[user][m.delete_at(rand(m.size))] = 1.0
      end
    end
    
    # user_a, user_b = users_ratings.keys[0], users_ratings.keys[-1]
    # users_ratings[user_a] = users_ratings[user_b]
  end
  
  it "should give euclidean distance" do
    rmend = Rmend.new
    user_a = "alice"
    user_b = "pat"
    rmend.euclidean(@users_ratings, user_a, user_b).should == 1
  end
  
end