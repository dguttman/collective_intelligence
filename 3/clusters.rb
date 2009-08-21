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
    clusters = []
    rows.each_index do |i| 
      clusters << Bicluster.new( rows[i], {:id => i} )
    end
    
    while clusters.size > 1
      lowest_pair = [0,1]
      closest = pearson_dist(clusters[0].vec, clusters[1].vec)
      
      # loop through every pair looking for the smallest distance
      (0..clusters.size).each do |i|
        ( (i+1)..clusters.size ).each do |j|
          # distances is the cache of distance calculations
          unless distances[ [ clusters[i].id, clusters[j].id ] ]
            distances[ [ clusters[i].id, clusters[j].id ] ] = pearson_dist(clusters[i].vec, clusters[j].vec)
            d = distances[ [ clusters[i].id, clusters[j].id ] ]
            if d < closest
              closest = d
              lowest_pair = [i, j]
            end  
          end
        end
      end
      
      #calculate the average of the two clusters
      close_vec_1 = clusters[ lowest_pair[0] ].vec
      close_vec_2 = clusters[ lowest_pair[1] ].vec
      merge_vec = []
      close_vec_1.each_index do |i|
        merge_vec[i] = ( close_vec_1[i] + close_vec_2[i] ) / 2.0
      end
      
      #create the new cluster
      new_cluster = Bicluster.new( merge_vec, { :left => clusters[lowest_pair[0]], :right => clusters[lowest_pair[1]], :distance => closest, :id => current_cluster_id } )
      
      #cluster ids that weren't in the original set are negative
      current_cluster_id -= 1
      clusters.delete_at(lowest_pair[1])
      clusters.delete_at(lowest_pair[0])
      clusters << new_cluster
    end
    
    return clusters[0]

  end
  
end
