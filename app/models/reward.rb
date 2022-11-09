class Reward < ApplicationRecord
  belongs_to :user
  belongs_to :creator, foreign_key: :creator_id, class_name: "User", optional: true

  enum category: {
    quest: "quest",
    race: "race",
    talent_invite: "talent_invite",
    other: "other",
    bounty: "bounty",
    ambassador: "ambassador",
    contributor: "contributor",
    contractor: "contractor"
  }

  validates :amount, presence: true
  validates :identifier, uniqueness: true, if: -> { identifier.present? }
end
