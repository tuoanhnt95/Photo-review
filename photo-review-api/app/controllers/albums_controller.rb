class AlbumsController < ApplicationController
  def index
    @albums = Album.all
    if @albums
      render json: @albums.to_json, status: :ok
    else
      render json: { error: 'No albums found' }, status: :not_found
    end
  end

  def new
    @album = Album.new
  end

  def create
    @album = Album.new(album_params)
    if @album.save
      redirect_to albums_path, notice: 'Album was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
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

  def album_params
    params.permit(:name, :expiry_date)
  end
end
