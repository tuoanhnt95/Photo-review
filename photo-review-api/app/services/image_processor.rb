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
    processed_image_urls = []

    @files.each do |file|
      p 'file in service object loop:'
      p file
    #   p file.content_type
    #   p file.tempfile
      file_path = file.tempfile.path
      p file_path
    #   p file.tempfile.path.split('/').last
    #   p file.tempfile.path.split('/').last.split('.').last
    #   p file.tempfile.path.split('/').last.split('.').last.downcase
    #   p file.tempfile.path.split('/').last.split('.').last.downcase.in?(['jpg', 'jpeg', 'png'])
      # file = 'file_example_JPG_1MB.jpeg'
      filename = file.original_filename

      use_magicload = image_uses_magicload(filename)
      image = if use_magicload
        MiniMagick::Image.new(file_path).format 'jpg'
      else
        Vips::Image.new_from_file file_path
      end

      result_file = resize_image(image, use_magicload, @upload_option)

      unless use_magicload
        result_file = result_file.write_to_file image_name(filename)
      end
      p 'processed image url in service object loop:'
      p result_file
      # result = Cloudinary::Uploader.unsigned_upload(
      #   result_file.path,
      #   "photo_review",
      #   :public_id => @album_id.to_s + "_" + filename,
      #   :overwrite => true
      # )

        # :folder => "myfolder/mysubfolder/", :public_id => "my_dog", :overwrite => true,
        # :notification_url => "https://mysite.example.com/notify_endpoint", :resource_type => "video")
      result = result_file.path
      processed_image_urls.push(result)
    end
    p 'processed_image_urls'
    p processed_image_urls
    processed_image_urls
  end

  # def upload_image_to_cloudinary(image)
  #   upload_preset = Cloudinary::Api.create_upload_preset(
  #     name: 'photo_review',
  #     unsigned: true
  #   )
  # end

  private

  def image_params
    params.permit(:image, :album_id, :upload_option, :files => [])
  end

  def set_image
    # @image = Image.find(params[:id])
    @image = Vips::Image.new_from_file(file)
  end

  # remove extension
  def image_name(file_name)
    "#{file_name.split('.')[0]}.jpg"
  end

  def image_extension(file_name)
    file_name.split('.')[1].downcase
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
