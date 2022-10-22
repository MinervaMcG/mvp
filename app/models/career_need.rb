class CareerNeed < ApplicationRecord
  belongs_to :career_goal

  update_index("talents") { career_goal.talent }
  
end
