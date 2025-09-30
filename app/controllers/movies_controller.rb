class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings

    # Determine current sort (from params or session)
    @sort = params[:sort_by] || session[:sort_by]

    # Determine ratings to show
    if params[:ratings]
      # User submitted ratings (Hash or Array)
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
    if (params[:ratings].nil? || params[:sort_by].nil?) &&
      (session[:ratings].present? || session[:sort_by].present?) &&
      !(params[:ratings].present? && params[:sort_by].present?)
      redirect_to movies_path(sort_by: session[:sort_by], ratings: session[:ratings]) and return
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
