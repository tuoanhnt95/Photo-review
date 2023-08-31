class AlbumsController < ApplicationController
  before_action :set_album, only: %i[ show update destroy ]
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  # GET /albums
  def index
    @albums = Album.all
    covers = []
    @albums.each do |album|
      album_cover = album.photos.first.image
      covers.push(album_cover)
    end

    render json: [@albums, covers]
  end

  # GET /albums/1
  def show
    render json: @album
  end

  # POST /albums
  def create
    @album = Album.new(album_params)
    # @album.user = current_user
    @album.user = User.first

    if @album.save
      render json: @album, status: :created, location: @album
    else
      render json: @album.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /albums/1
  def update
    if @album.update(album_params)
      render json: @album
    else
      render json: @album.errors, status: :unprocessable_entity
    end
  end

  # DELETE /albums/1
  def destroy
    @album.destroy
  end

  private

  def set_album
    @album = Album.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def album_params
    params.require(:album).permit(:name, :expiry_date, :user_id)
  end
end
