class Bicluster
  attr_reader :vec, :id, :left, :right, :distance

  def initialize(vec, params={})
    @vec = vec
    @left = params[:left] 
    @right = params[:right]
    @distance = params[:distance] 
    @id = params[:id]
    @distance ||= 0.0
  end
end
