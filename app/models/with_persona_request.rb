class WithPersonaRequest < ApplicationRecord
  # Month is an integer 1 through 12
  # Year is an integer

  validates :month, presence: true
  validates :year, presence: true

  def self.current_month_persona_request
    WithPersonaRequest.find_or_create_by!(
      month: Date.today.month,
      year: Date.today.year
    )
  end
end
