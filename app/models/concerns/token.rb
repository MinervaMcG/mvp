module Token
  extend ActiveSupport::Concern

  included do
    include ::TokenImageUploader::Attachment(:token_image)

    belongs_to :user

    validates :address, presence: true

    scope :visible, -> { where(show: true) }
  end
end
