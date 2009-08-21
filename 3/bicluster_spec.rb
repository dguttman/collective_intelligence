require 'bicluster'

describe Bicluster do
  it "initialize" do
    vec = ([0,0,1,1,0,1])
    bc = Bicluster.new(vec)
  end
end
