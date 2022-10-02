require "image_processing/mini_magick"

class TokenImageUploaderJob < ApplicationJob
  queue_as :low
  sidekiq_options retry: false

  MEGABYTES = 1024.0 * 1024.0

  def perform(token_id:, token_class:, image_url:)
    token = token_class.constantize.find(token_id)

    image = MiniMagick::Image.open(image_url)
    size = image.size.to_f / MEGABYTES
    width = image.width.to_f
    height = image.height.to_f

    processed_image = ImageProcessing::MiniMagick.source(image_url)

    processed_image = adjust_image_quality(processed_image, size)
    processed_image = adjust_image_dimensions(processed_image, width, height)

    token.token_image = processed_image
    token.save!
  end

  private

  def adjust_image_quality(processed_image, size)
    # Adjusts the file quality based on the file size in MB
    if size > 10
      processed_image.saver(quality: 10)
    elsif size > 1
      processed_image.saver(quality: 50)
    else
      processed_image.saver(quality: 75)
    end
  end

  def adjust_image_dimensions(processed_image, width, height)
    # Adjusts the file dimensions based on the file current width and height in pixels
    if width > 10000 || height > 10000
      processed_image.resize_to_limit!(width / 20, height / 20)
    elsif width > 5000 || height > 5000
      processed_image.resize_to_limit!(width / 10, height / 10)
    elsif width > 1000 || height > 1000
      processed_image.resize_to_limit!(width / 2, height / 2)
    else
      processed_image.resize_to_limit!(width, height)
    end
  end
end
