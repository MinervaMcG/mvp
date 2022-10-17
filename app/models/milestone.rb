class Milestone < ApplicationRecord
  has_paper_trail

  belongs_to :talent

  has_many :milestone_images, dependent: :destroy
  accepts_nested_attributes_for :milestone_images, allow_destroy: true
  validates_associated :milestone_images

  enum category: {Position: "Position", Education: "Education", Other: "Other"}
end
