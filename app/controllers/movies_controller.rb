class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
  
    # ratings
    if params[:ratings].present?
      @ratings_to_show = params[:ratings].keys
      session[:ratings] = params[:ratings]
    elsif params[:commit] == "Refresh"
      # user hit Refresh with nothing checked → show all
      @ratings_to_show = @all_ratings
      session.delete(:ratings)
    elsif session[:ratings].present?
      # no params, but session exists → remember previous selections
      @ratings_to_show = session[:ratings].keys
    else
      # first time → show all
      @ratings_to_show = @all_ratings
    end
  
    # sort
    if params[:sort_by].present?
      @sort_by = params[:sort_by]
      session[:sort_by] = @sort_by
    elsif session[:sort_by].present?
      @sort_by = session[:sort_by]
    else
      @sort_by = nil
      Rails.logger.debug "No sort"
    end
  
    # redirect to RESTful URL if missing params
    if (params[:ratings].nil? && params[:sort_by].nil?) &&
       (session[:ratings].present? || session[:sort_by].present?)
      redirect_to movies_path(sort_by: session[:sort_by], ratings: session[:ratings]) and return
    end
  
    # movies + highlighting
    @movies = Movie.with_ratings(@ratings_to_show)
    case @sort_by
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
