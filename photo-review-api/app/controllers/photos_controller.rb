require 'open-uri'

class PhotosController < ApplicationController
  before_action :set_photo, only: %i[ show update destroy ]
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  # GET /albums/:album_id/photos
  def index
    @photos = Photo.all

    render json: @photos
  end

  # GET /albums/:album_id/photos/:id
  def show
    render json: @photo
  end

  # POST /albums/:album_id/photos
  def create
    p 'photo_params'
    image_urls = ImageProcessor.call(photo_params)

    # save the urls to the database
    image_urls.each do |url|
      @photo = Photo.new(photo_params[:album_id])
      if @photo.save
        file_cloudinary_url = URI.open(url)
        @photo.image.attach(
          io: file_cloudinary_url,
          filename: url.split('/').last.split('.').first,
          content_type: 'image/jpg'
        )
        redirect to @photo, notice: 'Uploaded successfully.'
      else
        render json: @photo.errors, status: :unprocessable_entity
      end
    end
    p 'image_urls after saving in dtb'
    p image_urls
  end

  # PATCH/PUT /albums/:album_id/photos/:id
  def update
    if @photo.update(photo_params)
      render json: @photo
    else
      render json: @photo.errors, status: :unprocessable_entity
    end
  end

  # DELETE /albums/:album_id/photos/:id
  def destroy
    @photo.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_photo
      @photo = Photo.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def photo_params
      params.permit(:image, :album_id, :upload_option, :files => [])
    end
end
