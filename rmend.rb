class Rmend
  
  # Returns a distance-based similarity score for subject_a and subject_b
  # subjects_ratings is a hash with format {"subject_a" => {"object_a" => 1.0, "object_b" => 0.0...}, "subject_b" => {"object_a" => 0.0, "object_c" => 1.0}}
  # subject_a/b are keys of interest of the subjects_ratings hash
  def euclidean(subjects_ratings, subject_a, subject_b)
    subject_a_ratings = subjects_ratings[subject_a]
    subject_b_ratings = subjects_ratings[subject_b]
    objects = (subject_a_ratings.keys + subject_b_ratings.keys).uniq
    
    sum_diff_sq = 0.0
    objects.each do |object|
      a_rating = subject_a_ratings[object] || 0.0
      b_rating = subject_b_ratings[object] || 0.0
      diff_sq = (a_rating - b_rating) ** 2
      sum_diff_sq += diff_sq
    end
    return 1 / (1 + sum_diff_sq)
  end
  
  # Returns pearson correlation coefficient for subject_a and b
  # subjects_ratings is a hash with format {"subject_a" => {"object_a" => 1.0, "object_b" => 0.0...}, "subject_b" => {"object_a" => 0.0, "object_c" => 1.0}}
  # subject_a/b are keys of interest of the subjects_ratings hash
  def pearson(subjects_ratings, subject_a, subject_b)
    subject_a_ratings = subjects_ratings[subject_a]
    subject_b_ratings = subjects_ratings[subject_b]
    objects = subject_a_ratings.keys & subject_b_ratings.keys

    n = objects.size
    return 0 if n==0
    
    sum_a = objects.inject(0){|sum, object| sum + subject_a_ratings[object]}
    sum_b = objects.inject(0){|sum, object| sum + subject_b_ratings[object]}
    
    sum_a_sq = objects.inject(0){|sum, object| sum + ( subject_a_ratings[object] ** 2 )}
    sum_b_sq = objects.inject(0){|sum, object| sum + ( subject_b_ratings[object] ** 2 )}
    
    sum_products = objects.inject(0){|sum, object| sum + ( subject_a_ratings[object] * subject_b_ratings[object] )}

    num = sum_products - (sum_a * sum_b / n)
    den = Math.sqrt( (sum_a_sq - (sum_a ** 2)/n) * (sum_b_sq - (sum_b ** 2)/n) )

    return 0 if den == 0
    
    r = num/den
    return r
  end
  
  # Returns list of subjects most similar to the given subject
  # Number of results is an optional param.
  def top_matches(subjects_ratings, subject, n=5)
  	scores = subjects_ratings.map do |critic, objects|
      unless subject == critic
			  r = pearson(subjects_ratings, subject, critic)
			  [r, critic]
		  end
  	end

  	matches = scores.compact.sort.reverse[0..n-1]
    return matches
  end
  
  # Returns list of objects unrated by the subject 
  # With ratings weighted for the subject
  def recommendations(subjects_ratings, subject)
    totals = {}
    similarity_sums = {}
    subject_objects = subjects_ratings[subject].keys
    
    subjects_ratings.keys.each do |critic|
      next if subject == critic
      similarity = pearson(subjects_ratings, subject, critic)
      next if similarity <= 0
      
      critic_objects = subjects_ratings[critic].keys
      critic_objects.each do |critic_object|
        unless subject_objects.include? critic_object
          totals[critic_object] ||= 0
          totals[critic_object] += subjects_ratings[critic][critic_object] * similarity

          similarity_sums[critic_object] ||= 0
          similarity_sums[critic_object] += similarity
        end
      end
      
    end

    rankings = []
    
    totals.each do |object, total|
      rankings << [(total/similarity_sums[object]), object]
    end

    recs = rankings.sort.reverse
    
    return recs
  end
  
end