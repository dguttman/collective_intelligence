class Clusters
  
  def self.read_file(filename)
    lines = File.open(filename, "r").readlines
    
    # First line is the column titles
    col_names = lines[0].strip.split("\t")[1..-1]
    row_names = []
    data = []
    
    lines[1..-1].each do |line|
      p = line.strip.split("\t")
      # First column in each row is the row name
      row_names << p[0]
      # The data for this row is the remainder of the row
      row_data = []
      p[1..-1].each do |x|
        row_data << x.to_f
      end
      data << row_data
    end
    
    return row_names, col_names, data
  end
  
  def self.pearson_dist(vector_a, vector_b)

    n = vector_a.size
    return 0 if n==0
    
    sum_a = vector_a.inject(0) { |sum, value| sum + value }
    sum_b = vector_b.inject(0) { |sum, value| sum + value }
    
    sum_a_sq = vector_a.inject(0) { |sum, value| sum + ( value ** 2 ) }
    sum_b_sq = vector_b.inject(0) { |sum, value| sum + ( value ** 2 ) }
    
    sum_products = 0
    vector_a.each_with_index do |value_a, i|
      value_b = vector_b[i]
      sum_products += value_a * value_b
    end
    
    num = sum_products - (sum_a * sum_b / n)
    den = Math.sqrt( (sum_a_sq - (sum_a ** 2)/n) * (sum_b_sq - (sum_b ** 2)/n) )

    if den == 0
      r = 0 
    else
      r = num/den
    end
    
    return 1.0 - r
  end

  def h_cluster(rows)
    distances = {}
    current_cluster_id = -1

    # Clusters are initially just rows
    cluster = []
    rows.each_index do |i| 
      cluster << Bicluster.new(rows[i], id=i)
    end
    
    while cluster.size > 1
      lowest_pair = [0,1]
      closest = pearson_dist(cluster[0.vec], cluster[1].vec)
    end

  end
  
end
