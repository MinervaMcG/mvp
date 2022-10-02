require "image_processing/mini_magick"

class TokenImageUploader < Shrine
  plugin :validation_helpers

  Attacher.validate do
    # Validate that the image file can't be bigger than 0.5 MB
    # validate_max_size 0.5 * 1024 * 1024
  end
end
