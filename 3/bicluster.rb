class Bicluster
  attr_reader :vec

  def initialize(vec, left=nil, right=nil, distance=0.0, id=nil)
    @vec, @left, @right, @distance, @id = vec, left, right, distance, id
  end
end
