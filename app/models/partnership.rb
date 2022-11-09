class Partnership < ApplicationRecord
  include ::BannerUploader::Attachment(:banner)
  include ::ProfilePictureUploader::Attachment(:logo)

  belongs_to :invited, class_name: "Invite", foreign_key: "invite_id", optional: true

  has_many :invites

  has_one :discovery_row

  validates :button_url, allow_blank: true, format: {with: URI::DEFAULT_PARSER.make_regexp}
  validates :name, presence: true, uniqueness: true
  validates :twitter_url, allow_blank: true, format: {with: URI::DEFAULT_PARSER.make_regexp}
  validates :website_url, allow_blank: true, format: {with: URI::DEFAULT_PARSER.make_regexp}
end
