class UserDomain < ApplicationRecord
  belongs_to :user

  validates :domain, :wallet, :chain_id, presence: true

  validates :user_id, uniqueness: {scope: [:wallet, :domain, :chain_id]}

  enum provider: {
    unstoppable_domains: "unstoppable_domains",
    ens: "ens"
  }
end
