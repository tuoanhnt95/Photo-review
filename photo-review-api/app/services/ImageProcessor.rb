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
    # if file is not image -> error

    # if file is raw file, convert to .jpg using magickload
    # else, convert to .jpg using ffmpeg
    # give error if fail
    # file = 'Image_test.png'

    # Fujifilm .RAF takes a very long time to convert (about 20 seconds)
    # does not work with Leica .DNG
    file = 'Leica_Q2_Shotkit-7-2.DNG'
    use_magicload = image_uses_magicload(file)
    image = if use_magicload
              MiniMagick::Image.new(file).format 'jpg'
            else
              Vips::Image.new_from_file file
            end

    resize_image(image, use_magicload)
  end
  # TODO: upload the image to CLoudinary

  private

  def image_params
    params.require(:image).permit(:image)
  end

  def set_image
    # @image = Image.find(params[:id])
    @image = Vips::Image.new_from_file(file)
  end

  # remove extension
  def image_name(image_name)
    "#{image_name.split('.')[0]}.jpg"
  end

  def image_extension(image_name)
    image_name.split('.')[1].downcase
  end

  def image_uses_magicload(image)
    magickload_formats = %w[arw cr2 crw dng nef nrw orf pef raf rw2 srw]
    image_extension(image).in? magickload_formats
  end

  def resize_image(image, loader, option = 1)
    resized_width, resized_height = get_image_resized(option)
    return image.resize "#{resized_width}x#{resized_height}" if loader

    Vips::Image.thumbnail(image_name(image.filename), resized_width, height: resized_height)
  end

  def get_image_resized(option)
    case option
    when 2
      [1920, 1350]
    when 3
      [2100, 1600]
    when 4
      [2400, 1600]
    else
      [1920, 1080]
    end
  end

  def set_file
    # @file = params[:image]
  end
end
