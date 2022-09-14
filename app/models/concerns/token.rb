module Token
  extend ActiveSupport::Concern

  included do
    belongs_to :user

    validates :address, presence: true
  end
end
