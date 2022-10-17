class Connection < ApplicationRecord
  belongs_to :user
  belongs_to :connected_user, foreign_key: :connected_user_id, class_name: "User"

  validates :connected_at, presence: true
  validates :user_id, uniqueness: {scope: :connected_user_id}

  # Try reading it like this:
  # user is a super connection of connected_user
  # user is a supporter of connected_user
  # user is supporting the connected_user
  # user is a follower of connected_user
  # user is following the connected_user
  enum connection_type: {
    super_connection: 1,
    supporter: 2,
    supporting: 3,
    follower: 4,
    following: 5
  }

  def refresh_connection!
    return false if user.id == connected_user.id

    connected_at = user.connected_with_since(connected_user)
    user_invested_amount = user.amount_invested_in(connected_user)
    connected_user_invested_amount = connected_user.amount_invested_in(user)
    connection_type = calculate_connection_type(user_invested_amount, connected_user_invested_amount)

    return destroy! unless connection_type

    update!(
      user_invested_amount: user_invested_amount,
      connected_user_invested_amount: connected_user_invested_amount,
      connection_type: connection_type,
      connected_at: connected_at
    )

    self
  end

  private

  def calculate_connection_type(user_invested_amount, connected_user_invested_amount)
    return 1 if user_invested_amount.to_i.positive? && connected_user_invested_amount.to_i.positive?
    return 2 if connected_user_invested_amount.to_i.positive?
    return 3 if user_invested_amount.to_i.positive?
    return 4 if user.following.find_by(user_id: connected_user_id).present?
    return 5 if connected_user.following.find_by(user_id: user_id).present?
  end
end
