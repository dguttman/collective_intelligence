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
  
  # Returns the best matches for person from the prefs dictionary.
  # Number of results is an optional param.
  # The similarity method is a block.
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
    
    p "recs: #{recs.inspect} -- TRACE:rmend.rb:"
    
    return recs
  end
  
end


class OldRmend
  # Returns a distance-based similarity score for person1 and person2
  # Defines a 2-d pref space, then calculates the distance.
  def euclidean(people, person1, person2)
  	rating_diff = lambda {|item| 
  	  people[person1][item] - people[person2][item]
  	}
    
  	sum_of_squares = people[person1].inject(0.0) do |sum, rating| 
  		people[person2][rating.first] ? sum + (rating_diff[rating.first] ** 2) : sum
  	end
  	return "Sum was 0" if sum_of_squares == 0.0
  	#errata
  	#
  	1 / (1 + Math.sqrt(sum_of_squares))
  end

  # Returns the Pearson correlation coefficient for p1 and p2
  # Pearson corrects for 'grade inflation'
  # values closer to 1 mean higher correlation
  def pearson(people, p1, p2)

  	# Iterate through each rating in common,
  	# Building for each user
  	#  1) the sum of all the preferences
  	#  2) the sum of all the squares
  	# As well as the sum of all the products
  	sum1 = sum2 = sum1_sq = sum2_sq = length = 0
  	people[p2][people[p1].to_a.first.first]
  	sum_of_products = people[p1].inject(0) do |product_sum, rating|
  		if people[p2][rating.first] 
  			sum1 += people[p1][rating.first]
  			sum2 += people[p2][rating.first]
  			sum1_sq += people[p1][rating.first] ** 2
  			sum2_sq += people[p2][rating.first] ** 2
  			length += 1
  			product_sum + people[p1][rating.first] * people[p2][rating.first]
  		else
  			product_sum
  		end
  	end

  	# Do math..
  	# Calculate Pearson score
  	num = sum_of_products - (sum1 * sum2 / length)
  	den = Math.sqrt((sum1_sq - (sum1 ** 2) / length) * (sum2_sq - (sum2 ** 2) / length))

  	return "den == 0" if den == 0

  	num/den

  end

  # Returns the best matches for person from the prefs dictionary.
  # Number of results is an optional param.
  # The similarity method is a block.
  def top_matches(people, person, n=5)
  	scores = people.map do |critic, items|
  		unless person == critic
  			[(block_given? ? yield(people, person, critic) : pearson(people, person, critic)), critic]
  		end
  	end

  	scores.compact.sort.reverse[0..n]

  end


  # Gets recommendations for a person by using a weighted average 
  # of every other user's rankings 
  def recommendations(people, person)

  	# totalweighted rating of the items for a given person
  	totals = Hash.new(0.0)

  	# total similarity of the people to the given person for the items
  	sim_sums = Hash.new(0.0)

  	#for each of the people...
  	people.each do |critic, items|
  		next if critic == person

  		# find the similarity between the given person and the critic
  		sim = block_given? ? yield(people, person, critic) : pearson(people, person, critic)

  		next if sim <= 0

  		#for each of the similar people' people
  		people[critic].each do |item, rating|
  			next if people[person][item] 

  			# add a rating based on the similarity of the person to the critic
  			# to the sum of people for the given item
  			totals[item] += people[critic][item] * sim
  			# and add the similarity to the total similarity sum for that item
  			sim_sums[item] += sim
  		end
  	end

  	# create an array of rankings by...
  	#	dividing each total ranking by the total similarity of all people of that item
  	#	to normalize the rankings, so that items reviewed by a lot of people
  	#	aren't given a big advantage
  	rankings = totals.map {|item, total| [total/sim_sums[item], item] }
  	rankings.sort.reverse
  end

  # Take the original hash, which is indexed by people
  # and transform it to be indexed by item
  def transform_hash(people)
  	 h = Hash.new {|hash, key| hash[key] = {}}

  	 people.each do |person, ratings|
  	   ratings.each {|item, rating| 	h[item][person] = rating }
  	 end

  	 h

  end

end