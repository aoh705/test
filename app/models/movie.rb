class Movie < ActiveRecord::Base
  # Return all unique ratings that exist in the DB
  def self.all_ratings
    Movie.distinct.pluck(:rating)
  end

  # Return movies with the given ratings
  def self.with_ratings(ratings_list)
    if ratings_list.nil?
      all
    else
      where(rating: ratings_list)
    end
  end
end