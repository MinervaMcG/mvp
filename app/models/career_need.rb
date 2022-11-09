class CareerNeed < ApplicationRecord
  belongs_to :career_goal

  update_index("talents") { career_goal.talent }

  after_save :touch_talent

  private

  def touch_talent
    career_goal.talent.touch
  end
end
