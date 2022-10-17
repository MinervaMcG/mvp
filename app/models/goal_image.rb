class GoalImage < ApplicationRecord
  include ::ImageUploader::Attachment(:image)

  belongs_to :goal
end
