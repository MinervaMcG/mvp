class Tag < ApplicationRecord
  belongs_to :discovery_row, optional: true
  has_many :user_tags, dependent: :destroy
  has_many :talents, through: :user_tags

  validates :description, presence: true

  # Elasticsearch index update
  update_index("talents", :talents)

  scope :visible, -> { where(hidden: false) }

  def to_s
    description
  end
end
