class CareerGoal < ApplicationRecord
  include ::CareerGoalImageUploader::Attachment(:image)

  has_paper_trail

  belongs_to :talent
  has_many :goals
  has_many :career_needs

  def to_s
    "#{target_date}: #{description}"
  end

  update_index("talents") { talent }

  after_save :touch_talent

  private

  def touch_talent
    talent.touch
  end

end
