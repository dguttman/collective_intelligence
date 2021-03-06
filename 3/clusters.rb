require "RMagick"
require "bicluster"

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

  def self.tanamoto_dist(vector_a, vector_b)
    c1, c2, shared = 0, 0, 0

    for i in (0...vector_a.size)
      c1 += 1 if vector_a[i] != 0 # in vector_a
      c2 += 1 if vector_b[i] != 0 # in vector_b
      shared += 1 if vector_a[i] != 0 && vector_b[i] != 0 # in both
    end

    return 1.0 - ( shared.to_f / (c1 + c2 - shared) )

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

  def self.h_cluster(rows)
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
      ( 0..(clusters.size-1) ).each do |i|
        ( (i+1)..(clusters.size-1) ).each do |j|
          # distances is the cache of distance calculations
          unless distances[ [ clusters[i].id, clusters[j].id ] ]
            distances[ [ clusters[i].id, clusters[j].id ] ] = pearson_dist(clusters[i].vec, clusters[j].vec)
            d = distances[ [ clusters[i].id, clusters[j].id ] ]
            if d < closest
              closest = d
              lowest_pair = [i, j]
            end  
            #p "lowest_pair for h_cluster: #{lowest_pair.join("-")}"      
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

  def self.k_cluster(rows, k=4)
    # Determine the minimum and maximum values for each point
    ranges = []
  
    (0...rows[0].size).each do |i|
      temp_a = []
      for row in rows
        temp_a << row[i]
      end
      min = temp_a.min
      max = temp_a.max
      ranges << [min, max]
    end
    
    # Create k randomly placed centroids
    clusters = []
    (0...k).each do |j|
      centroid = []
      (0...rows[0].size).each do |i|
        centroid << rand * (ranges[i][1] - ranges[i][0]) + ranges[i][0]
      end
      clusters << centroid
    end

    last_matches = nil
    (0...100).each do |t|
      p "Iteration #{t}"
      best_matches = Array.new(k) { [] }
      
      # Find which centroid is the closest for each row
      rows.each_index do |j|
        row = rows[j]
        best_match = 0
        (0...k).each do |i|
          d = pearson_dist(clusters[i], row)
          p "d = #{d}"
          best_match = i if d < pearson_dist(clusters[best_match], row)
        end
        p "best_match = #{best_match}"
        best_matches[best_match] << j
        p "best_matches: #{best_matches.inspect}"
      end


      # if the results are the same as last time this is complete
      break if best_matches == last_matches

      last_matches = best_matches
    
      # Move the centroids to the average of their members
      (0...k).each do |i|
        avgs = [0.0] * rows[0].size
        if best_matches[i].size > 0
          best_matches[i].each do |row_id|
            (0...rows[row_id].size).each do |m|
              avgs[m] += rows[row_id][m]
            end
          end
          (0...avgs.size).each do |j|
            avgs[j] /= best_matches[i].size
          end
          clusters[i]=avgs
        end
        return best_matches
      end
    end 
  end


  def self.print_cluster(cluster, labels=nil, n=0)
    # indent to make a hierarchy layout
    (0..n).each {|i| print ' ' }

    if cluster.id < 0
      # negative id means that this is branch
      p '-' 
    else
      # positive id means that this is an endpoint
      if labels == nil
        p cluster.id
      else
        p labels[cluster.id]
      end
    end
    
    # now print the right and left branches
    if cluster.left != nil
      print_cluster(cluster.left, labels, n = n+1)
    end

    if cluster.right != nil
      print_cluster(cluster.right, labels, n = n+1)
    end

  end

  def self.get_height(cluster)
    # is this an endpoint? Then the height is just 1
    if cluster.left == nil && cluster.right == nil
      return 1
    end

    # otherwise the height is the same as the heights of each branch
    return get_height(cluster.left) + get_height(cluster.right)
  end

  def self.get_depth(cluster)
    # The distance of an endpoint is 0.0
    if cluster.left == nil && cluster.right == nil
      return 0
    end

    # the distance of a branch is the greater of its two sides plus its own distance
    return [ get_depth(cluster.left), get_depth(cluster.right) ].max + cluster.distance
  end

  def self.draw_dendrogram(cluster, labels, jpeg='clusters.jpg')
    # height and width
    h = get_height(cluster) * 20
    w = 1200
    depth = get_depth(cluster)
    
    # width is fixed, so scale distances accordingly
    scaling = (w - 150.0)/depth

    # create a new image with a white background
    p "Creating Magick image: #{jpeg}"
    canvas = Magick::Image.new( w, h )
    gc = Magick::Draw.new

    gc.stroke( 'red' )
    gc.line( 0, h/2, 10, h/2 )

    # draw the first node
    draw_node(gc, cluster, 10, (h/2), scaling, labels)

    gc.draw(canvas)
    canvas.write(jpeg)
  end

  def self.draw_node(gc, cluster, x, y, scaling, labels)
    #p "drawing node #{cluster.id}"
    if cluster.id < 0
      h1 = get_height(cluster.left) * 20
      h2 = get_height(cluster.right) * 20
      top = y - (h1 + h2)/2
      bottom = y + (h1 + h2)/2
      
      # Line length
      ll = cluster.distance * scaling

      # Vertical line from this cluster to children
      gc.stroke( 'red' )
      gc.line( x, top + h1/2, x, bottom - h2/2 )

      # horizontal line to left item
      gc.line( x, top + h1/2, x+ll, top+h1/2 )

      # horizontal line to right item
      gc.line( x, bottom - h2/2, x + ll, bottom - h2/2 )

      # call methods to draw the left and right nodes
      draw_node(gc, cluster.left, x+ll, top+h1/2, scaling, labels)
      draw_node(gc, cluster.right, x+ll, bottom-h2/2, scaling, labels)

    else
      # if this is an endpoint draw the item label
      gc.stroke('transparent')
      gc.fill('black')
      gc.text(x+5, y, labels[cluster.id])

    end
  end

  def self.rotate_matrix(data)
    new_data = []
    (0...data[0].size).each do |i|
      new_row = []
      (0...data.size).each do |j|
        new_row << data[j][i]
      end
      new_data << new_row
    end

    return new_data
  end

end
