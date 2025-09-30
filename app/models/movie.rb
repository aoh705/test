class Movie < ActiveRecord::Base
  # Return all ratings in the DB (unique, sorted)
  def self.all_ratings
    distinct.pluck(:rating).sort
  end

  # Return only movies with the given ratings
  def self.with_ratings(ratings_list)
    if ratings_list.nil? || ratings_list.empty?
      all
    else
      where(rating: ratings_list)
    end
  end
end