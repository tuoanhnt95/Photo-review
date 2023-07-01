class AlbumsController < ApplicationController
  def index
    @albums = Album.all
  end

  def new
    @album = Album.new
  end

  def create
    @album = Album.new(params[:album])
    @album.save
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def albums_params
    params.require(:album).permit(:name, :expiry_date)
  end
end
