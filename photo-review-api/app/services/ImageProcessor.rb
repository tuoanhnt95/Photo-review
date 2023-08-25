require 'mini_magick'
require 'vips'
require 'open-uri'

class ImageProcessor < ActionController::API
  # before_action :set_image, only: %i[convert resize initialize]
  # before_action :set_file, only: %i[convert]
  # skip_before_action :verify_authenticity_token
  # skip_before_action :authenticate_user!

  # def initialize
  # @image = image
  # end

  def create
    # processor = ImageProcessor.new(image_params)
    ImageProcessor.new(image_params)
  end

  def convert
    file = 'file_example_JPG_1MB.jpeg'
    use_magicload = image_uses_magicload(file)
    image = if use_magicload
              MiniMagick::Image.new(file).format 'jpg'
            else
              Vips::Image.new_from_file file
            end
    result = resize_image(image, use_magicload, 3)

    unless use_magicload
      result = result.write_to_file image_name(file)
    end

    result
  end

  private

  def image_params
    params.require(:image).permit(:image)
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

  def set_file
    # @file = params[:image]
  end
end
