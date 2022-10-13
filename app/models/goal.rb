class Goal < ApplicationRecord
  has_paper_trail

  belongs_to :career_goal

  has_many :goal_images, dependent: :destroy
  accepts_nested_attributes_for :goal_images, allow_destroy: true
  validates_associated :goal_images

  scope :due_halfway, -> { where("(created_at::DATE + CAST(ROUND((due_date - created_at::DATE)/2.0) AS INT)) = ?", Date.current) }
  scope :due_today, -> { where(due_date: Date.current) }

  def to_s
    "#{due_date}: #{description}"
  end
end
