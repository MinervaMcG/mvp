class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post

  def to_json
    {
      id: id,
      username: user.name,
      ticker: user.talent&.talent_token&.ticker,
      profilePictureUrl: user.profile_picture_url,
      text: text,
      created_at: created_at.to_s
    }
  end
end
