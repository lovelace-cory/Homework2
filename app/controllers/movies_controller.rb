class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @ratings = ["G", "PG", "PG-13", "R", "NC-17"]
    unless (@input = params.fetch(:ratings){session[:ratings]})
      @input = Hash.new
      @ratings.each do |rating|
        @input[rating]="yes"
      end
    end
    header = params.fetch(:sort){session[:sort]}
    if header == 'title'
      column = {:order => :title}
      @title_header = 'hilite'
    elsif header == 'release_date'
      column = {:order => :release_date}
      @date_header = 'hilite'
    end
    if params[:sort] != session[:sort]
      session[:sort] = header
      redirect_to :sort => header, :ratings => @input
    return
    end
    if params[:ratings] != session[:ratings]
      session[:sort] = header
      session[:ratings] = @input
      redirect_to :sort => header, :ratings => @input
    return
    end
    # operator foo.find_all_by_* functionality inherited through Movie < ActiveRecord::Base
    @movies = Movie.find_all_by_rating(@input.keys, column)
  end

  def new
    # default: render 'new' template
    @ratings = Movie.find(:all,:select=>"rating", :group => "rating").map(&:rating)
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end

