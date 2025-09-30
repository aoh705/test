class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
  
    # --- Determine ratings ---
    if params[:ratings]
      ratings_hash = params[:ratings].to_unsafe_h
      @ratings_to_show = ratings_hash.keys
    elsif session[:ratings]
      @ratings_to_show = session[:ratings].keys
    else
      @ratings_to_show = @all_ratings
    end
  
    # --- Determine sort ---
    @sort = params[:sort_by] || session[:sort_by]
  
    # --- Redirect to RESTful URL if any param is missing ---
    redirect_needed = false
    redirect_params = {}
  
    if params[:ratings].nil? && session[:ratings]
      redirect_needed = true
      redirect_params[:ratings] = session[:ratings]
    end
  
    if params[:sort_by].nil? && session[:sort_by]
      redirect_needed = true
      redirect_params[:sort_by] = session[:sort_by]
    end
  
    if redirect_needed
      redirect_to movies_path(redirect_params) and return
    end
  
    # --- Update session ---
    session[:ratings] = @ratings_to_show.map { |r| [r, "1"] }.to_h
    session[:sort_by] = @sort if @sort
  
    # --- Filter and sort movies ---
    @movies = Movie.with_ratings(@ratings_to_show)
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
