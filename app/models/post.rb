class Post < ApplicationRecord
  belongs_to :user

  has_many :comments, dependent: :destroy
  has_many :feed_posts, dependent: :destroy
  has_many :feeds, through: :feed_posts

  def to_json
    {
      id: id,
      text: text,
      created_at: created_at.to_s,
      comments: comments.count,
      user: {
        id: user.id,
        username: user.display_name.blank? ? user.username : user.display_name,
        ticker: user.talent&.talent_token&.display_ticker,
        contract_id: user.talent&.talent_token&.contract_id,
        profilePictureUrl: user.profile_picture_url,
        talentUrl: user.talent && user.talent.id != 1 ? "/u/#{user.username}" : nil,
        active: user.talent.active?
      }
    }
  end
end
