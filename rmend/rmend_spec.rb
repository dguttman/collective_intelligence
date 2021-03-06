require 'rmend'

def build_user_list
  users = %w(alice bob charlie david edgar frank george howard ishmael kelly lisa mary nancy oliver pat)
end

def build_merchant_list
  merchants = %w(apple bestbuy cadillac dunkindonuts ecco frog guess hardrock)
end

def create_random_ratings(subjects, objects)
  srand(400)
  subjects_ratings = {}
  subjects.each do |subject|
    n = rand(objects.size - 4) + 1 + 4
    m = objects.dup
    subjects_ratings[subject] = {}
    (1..n).each do |i|
      subjects_ratings[subject][m.delete_at(rand(m.size))] = rand(5.0)
    end
  end
  return subjects_ratings
end

describe Rmend do 
  before do
    @users = build_user_list
    @merchants = build_merchant_list
    
    @users_ratings = create_random_ratings(@users, @merchants)
    @rmend = Rmend.new
    
    # user_a, user_b = users_ratings.keys[0], users_ratings.keys[-1]
    # users_ratings[user_a] = users_ratings[user_b]
  end
  
  it "should give euclidean distance" do
    user_a = "alice"
    user_b = "pat"
    @rmend.euclidean(@users_ratings, user_a, user_a).should == 1
    
    @rmend.euclidean(@users_ratings, user_a, user_b).should <= 1
    @rmend.euclidean(@users_ratings, user_a, user_b).should >= 0
  end
  
  it "should give pearson r coefficient" do
    user_a = "alice"
    user_b = "charlie"
    @rmend.pearson(@users_ratings, user_a, user_a).should == 1

    @rmend.pearson(@users_ratings, user_a, user_b).should <= 1
    @rmend.pearson(@users_ratings, user_a, user_b).should >= -1
  end
  
  it "should return top matches for a user" do
    user_a = "alice"
    matches = @rmend.top_matches(@users_ratings, user_a, 8)
    matches.size.should == 8
    matches.each do |m|
      m[0].should <= 1
      m[0].should >= -1
    end
  end
  
  it "should return recommended merchants for a user" do
    user_a = "alice"
    recs = @rmend.recommendations(@users_ratings, user_a)
    recs.size.should == @merchants.size - @users_ratings[user_a].size
  end
  
end