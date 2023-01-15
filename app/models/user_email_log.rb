class UserEmailLog < ApplicationRecord
  belongs_to :user

  validates :user_id, uniqueness: true

  store_accessor :sent_at_data
end
