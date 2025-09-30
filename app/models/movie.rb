class Movie < ActiveRecord::Base
  def self.all_ratings
    %w(G PG PG-13 R)
  end

  def self.with_ratings(ratings)
    if ratings.nil? || ratings.empty?
      all
    else
      where(rating: ratings)
    end
  end
end