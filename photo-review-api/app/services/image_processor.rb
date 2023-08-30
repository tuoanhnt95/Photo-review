require 'mini_magick'
require 'vips'
require 'cloudinary'
require 'json'

class ImageProcessor < ApplicationService
  def initialize(image_params)
    @image_params = image_params
    @files = @image_params[:files]
    @upload_option = @image_params[:upload_option]
  end

  def call
    @files = @image_params[:files]
    processed_images = []
    p '-------------------'
    @files.each do |file|
      # file_name = image_name(file.original_filename)
      file_path = file.tempfile.path
      file_name = file.original_filename
      resized_width, resized_height = get_image_resized(@upload_option)
      use_magicload = image_uses_magicload(file.original_filename)

      cloudinary_image = if use_magicload
                           process_magicload(file_path, resized_width, resized_height)
                           # MiniMagick::Image.new(file_path).format 'jpg'
                         else
                           process_libvips(file_name, resized_width, resized_height)
                           # Vips::Image.new_from_file file_path
                         end
      result = cloudinary_public_id(cloudinary_image['secure_url'])
      processed_images.push(result)
    end
    p '-------------------'
    p 'processed_images'
    p processed_images
    p '-------------------'
    processed_images
  end

  private

  def process_magicload(file_path, resized_width, resized_height)
    image = MiniMagick::Image.new(file_path).format 'jpg'
    image.resize "#{resized_width}x#{resized_height}"
    upload_image_to_cloudinary(image.path)
    # IMPROVEMENT: upload to cloudinary from data stream, not write to file
    # Or write to jpg file and resize in libvips
    # convert_to_jpg_minimagick(file_path)
  end

  def process_libvips(file_name, resized_width, resized_height)
    image = Vips::Image.new_from_file file_name
    resized_image = Vips::Image.thumbnail image.filename, resized_width, height: resized_height
    jpg_converted_file_name = image_name(file_name)

    resized_image.write_to_file jpg_converted_file_name unless image_is_jpg(file_name)

    upload_image_to_cloudinary(jpg_converted_file_name)
  end

  def file_path_to_image(file, use_magicload)
    if use_magicload
      file.path
    else
      file.tempfile.path
    end
  end

  def upload_image_to_cloudinary(image_path)
    p '-------------------'
    p '-------------------'
    p 'uploading to cloudinary...'
    result = Cloudinary::Uploader.unsigned_upload(image_path, 'photo_review')
    p 'result from Cloudinary:'
    p result
    p '-------------------'
    p '-------------------'
    result
  end

  def convert_to_jpg_minimagick(file_path)
    MiniMagick::Tool::Magick.new do |magick|
      magick << file_path
      magick << 'jpg:-'
    end
  end

  def image_params
    params.permit(:image, :album_id, :upload_option, files: [])
  end

  def set_image
    # @image = Image.find(params[:id])
    @image = Vips::Image.new_from_file(file)
  end

  def cloudinary_public_id(cloudinary_url)
    cloudinary_url.split('/').last.split('.')[0]
  end

  # remove extension
  def image_name(file_name)
    "#{file_name.split('.')[0]}.jpg"
  end

  def image_extension(file_name)
    file_name.split('.')[1].downcase
  end

  def image_is_jpg(file_name)
    image_extension(file_name) == 'jpg' || image_extension(file_name) == 'jpeg'
  end

  def image_uses_magicload(file_name)
    magickload_formats = %w[arw cr2 crw dng nef nrw orf pef raf rw2 srw]
    image_extension(file_name).in? magickload_formats
  end

  def resize_image(image, loader, option = 1)
    resized_width, resized_height = get_image_resized(option)
    return image.resize "#{resized_width}x#{resized_height}" if loader

    Vips::Image.thumbnail image.filename, resized_width, height: resized_height
  end

  def get_image_resized(option)
    case option
    when 2
      [1920, 1080]
    when 3
      [1920, 1350]
    when 4
      [2100, 1600]
    when 5
      [2400, 1600]
    else
      [1080, 720]
    end
  end
end

      #   p file.content_type
      #   p file.tempfile
    #   p file.tempfile.path.split('/').last
    #   p file.tempfile.path.split('/').last.split('.').last
    #   p file.tempfile.path.split('/').last.split('.').last.downcase
    #   p file.tempfile.path.split('/').last.split('.').last.downcase.in?(['jpg', 'jpeg', 'png'])

          # result = Cloudinary::Uploader.unsigned_upload(
      #   result_file.path,
      #   "photo_review",
      #   :public_id => @album_id.to_s + "_" + filename,
      #   :overwrite => true
      # )

        # :folder => "myfolder/mysubfolder/", :public_id => "my_dog", :overwrite => true,
        # :notification_url => "https://mysite.example.com/notify_endpoint", :resource_type => "video")
