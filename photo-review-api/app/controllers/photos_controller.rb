# frozen_string_literal: true

# Photos controller
class PhotosController < ApplicationController
  before_action :set_photo, only: %i[show update destroy]
  before_action :set_album, only: %i[index create create_new_upload]
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  # GET /albums/:album_id/photos
  def index
    @photos = Photo.where(album_id: params[:album_id])
    # return photo objects with review results
    result = []
    @photos.each do |photo|
      photo_object = {}.merge(photo.attributes)
      photo_object[:review_results] = get_review_result(photo)
      result.push(photo_object)
    end
    render json: result
  end

  # GET /photos/:id
  def show
    render json: @photo
  end

  # POST /albums/:album_id/photos
  def create
    @album.increment!(:last_upload_batch)
    results = []

    photo_params[:files].each do |file|
      # whitelist file types
      next unless whitelist_file_types.include?(file.original_filename.split('.').last.downcase)

      upload = create_new_upload(file.original_filename)

      processed_image = ImageProcessor.call(file, photo_params[:upload_option], upload.id)
      photo = make_new_photo(processed_image)
      if photo.save
        results.push(photo)
        upload.update(progress: 100)
      else
        render json: photo.errors, status: :unprocessable_entity
      end
    end

    if results.empty?
      render(json: { error: 'Error uploading images' }, status: :unprocessable_entity)
    else
      render(json: results, status: :created)
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
    public_id = @photo.image
    @photo.destroy
    folder = 'photo_review/'
    Cloudinary::Uploader.destroy(folder + public_id)
  end

  private

  def whitelist_file_types
    %w[arw bmp cr2 crw dng heic jpg jpeg nef nrw orf pef png raf srw tif tiff]
  end

  def create_new_upload(file_name)
    Upload.create({
                    name: file_name,
                    progress: 15,
                    batch: @album.last_upload_batch,
                    album_id: photo_params[:album_id]
                  })
  end

  def get_review_result(photo)
    user = User.first
    reviews = photo.photo_user_reviews
    review_by_user = reviews.find { |review| review.user_id == user.id }
    # Only show result after current user has reviewed
    return nil if reviews.empty? || review_by_user.nil?

    values = map_review_value(reviews)
    if reviews_all_yes?(values)
      1
    elsif reviews_all_no?(values)
      0
    else
      2
    end
  end

  def map_review_value(reviews)
    reviews.map { |review| Review.find(review.review_id).value }
  end

  def reviews_all_yes?(values)
    values.all? { |value| value == 1 }
  end

  def reviews_all_no?(values)
    values.all?(&:zero?)
  end

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
                angle: 0,
                album_id: photo_params[:album_id]
              })
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_album
    @album = Album.find(params[:album_id])
  end

  def set_photo
    @photo = Photo.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def photo_params
    params.permit(:image, :angle, :album_id, :upload_option, files: [])
  end
end
