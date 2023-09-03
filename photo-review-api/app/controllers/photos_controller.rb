class PhotosController < ApplicationController
  before_action :set_photo, only: %i[show update destroy]
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  # GET /albums/:album_id/photos
  def index
    @photos = Photo.where(album_id: params[:album_id])

    render json: @photos
  end

  # GET /photos/:id
  def show
    render json: @photo
  end

  # POST /albums/:album_id/photos
  def create
    processed_images = ImageProcessor.call(photo_params)
    result = save_photos_to_db(processed_images)
    if result.empty?
      render(json: { error: 'Error uploading images' }, status: :unprocessable_entity)
    else
      render(json: result, status: :created)
    end
  end

  # PATCH/PUT /photos/:id
  def update
    if @photo.update(photo_params)
      render json: @photo
    else
      render json: @photo.errors, status: :unprocessable_entity
    end
  end

  # DELETE /photos/:id
  def destroy
    @photo.destroy
  end

  private

  def save_photos_to_db(processed_images)
    result = []
    processed_images.each do |img|
      photo = make_new_photo(img)
      if photo.save
        result.push(photo)
      else
        render json: photo.errors, status: :unprocessable_entity
      end
    end
    result
  end

  def make_new_photo(img)
    Photo.new({
                name: img[:img_name],
                image: img[:img_url],
                album_id: photo_params[:album_id]
              })
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_photo
    @photo = Photo.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def photo_params
    params.permit(:image, :album_id, :upload_option, files: [])
  end
end
