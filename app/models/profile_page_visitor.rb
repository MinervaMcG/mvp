class ProfilePageVisitor < ApplicationRecord
  has_encrypted :ip
  blind_index :ip

  belongs_to :user

  validates :ip, uniqueness: {scope: :user}
end
