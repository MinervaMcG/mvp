class MilestoneImage < ApplicationRecord
  include ::ImageUploader::Attachment(:image)

  belongs_to :milestone
end
