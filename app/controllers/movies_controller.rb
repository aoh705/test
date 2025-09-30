class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings

    # Determine current sort
    @sort = params[:sort_by] || session[:sort_by]

    # Determine ratings to show
    if params[:ratings]
      # User submitted ratings (Hash)
      @ratings_to_show = params[:ratings].is_a?(Hash) ? params[:ratings].keys : params[:ratings]
      # Store in session as a Hash for later
      session[:ratings] = @ratings_to_show.map { |r| [r, "1"] }.to_h
    elsif session[:ratings]
      # No ratings param, use session
      @ratings_to_show = session[:ratings].keys
    else
      # Default: show all ratings
      @ratings_to_show = @all_ratings
    end

    # Only redirect if missing params to maintain RESTful URLs
    if (params[:ratings].nil? && params[:sort_by].nil?) && (session[:ratings] || session[:sort_by])
      redirect_to movies_path(sort_by: @sort, ratings: session[:ratings]) and return
    end

    # Update session for sort
    session[:sort_by] = @sort if @sort

    # Fetch filtered movies
    @movies = Movie.with_ratings(@ratings_to_show)

    # Apply sorting
    case @sort
    when 'title'
      @movies = @movies.order(:title)
      @title_header = 'hilite bg-warning'
    when 'release_date'
      @movies = @movies.order(:release_date)
      @release_date_header = 'hilite bg-warning'
    end
  end


  # private

  # # Convert ActionController::Parameters to plain Hash with string keys
  # def normalized_ratings(ratings_param)
  #   case ratings_param
  #   when Hash
  #     ratings_param.stringify_keys
  #   when Array
  #     ratings_param.map { |r| [r, "1"] }.to_h
  #   else
  #     nil
  #   end
  # end

  # def ratings_changed?
  #   normalized_ratings(params[:ratings]) != session[:ratings]
  # end

  # def sort_changed?
  #   params[:sort_by] != session[:sort_by]
  # end

  # def update_session
  #   session[:sort_by] = @sort
  #   session[:ratings] = @ratings_to_show
  # end

  # def apply_sorting
  #   case @sort
  #   when "title"
  #     @title_header = 'hilite bg-warning'
  #     @movies = @movies.order(:title)
  #   when "release_date"
  #     @release_date_header = 'hilite bg-warning'
  #     @movies = @movies.order(:release_date)
  #   end
  # end

  # def index
  #   @all_ratings = Movie.all_ratings

  #   # --- ratings ---
  #   if params[:ratings].present?
  #     if params[:ratings].is_a?(Hash)
  #       @ratings_to_show = params[:ratings].keys
  #       session[:ratings] = params[:ratings]
  #     else # Array
  #       @ratings_to_show = params[:ratings]
  #       session[:ratings] = Hash[@ratings_to_show.map { |r| [r, "1"] }]
  #     end
  #   elsif params[:commit] == "Refresh"
  #     @ratings_to_show = @all_ratings
  #     session.delete(:ratings)
  #   elsif session[:ratings].present?
  #     @ratings_to_show = session[:ratings].keys
  #   else
  #     @ratings_to_show = @all_ratings
  #   end

  #   # --- sort ---
  #   if params[:sort_by].present?
  #     @sort_by = params[:sort_by]
  #     session[:sort_by] = @sort_by
  #   elsif session[:sort_by].present?
  #     @sort_by = session[:sort_by]
  #   else
  #     @sort_by = nil
  #   end

  #   # --- redirect to RESTful URL if missing params ---
  #   if (params[:ratings].nil? && params[:sort_by].nil?) &&
  #     (session[:ratings].present? || session[:sort_by].present?)
  #     redirect_to movies_path(sort_by: session[:sort_by], ratings: session[:ratings]) and return
  #   end

  #   # --- movies + highlighting ---
  #   @movies = Movie.with_ratings(@ratings_to_show)
  #   case @sort_by
  #   when 'title'
  #     @movies = @movies.order(:title)
  #     @title_header = 'hilite bg-warning'
  #   when 'release_date'
  #     @movies = @movies.order(:release_date)
  #     @release_date_header = 'hilite bg-warning'
  #   end
  # end 

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
