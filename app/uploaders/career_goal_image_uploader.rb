require "image_processing/mini_magick"

class CareerGoalImageUploader < ImageUploader
  Attacher.derivatives do |original|
    magick = ImageProcessing::MiniMagick.source(original)
    {default: magick.resize_to_limit!(900, 700)}
  end
end
