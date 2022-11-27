class User < ApplicationRecord
  has_paper_trail ignore: [:updated_at]

  include Clearance::User

  validate :role_is_valid, if: -> { role.present? }
  validate :email_and_credentials
  validate :validate_notification_preferences
  validate :username_is_valid
  validates :username, :email, uniqueness: true
  validates :wallet_id, uniqueness: true, if: -> { wallet_id.present? }

  belongs_to :invited, class_name: "Invite", foreign_key: "invite_id", optional: true
  belongs_to :race, optional: true

  has_many :invites
  has_many :user_tags
  has_many :tags, through: :user_tags

  has_one :talent
  has_one :user_email_log

  # Chat
  has_many :messagee, foreign_key: :receiver_id, class_name: "Message"
  has_many :senders, through: :messagee
  has_many :messaged, foreign_key: :sender_id, class_name: "Message"
  has_many :receivers, through: :messaged

  # Feed
  has_one :feed
  has_many :follows
  has_many :followers, through: :follows # only use to load users, never to count
  has_many :following, foreign_key: :follower_id, class_name: "Follow"
  has_many :comments
  has_many :posts
  has_many :notifications, as: :recipient
  has_many :quests
  has_many :connections

  # Rewards
  has_many :rewards

  # web3
  has_one :user_domain
  has_many :erc20_tokens
  has_many :erc721_tokens

  # Elasticsearch index update
  update_index("talents") { talent }

  after_save :touch_talent

  VALID_ROLES = ["admin", "basic", "moderator"].freeze

  enum profile_type: {
    supporter: "supporter",
    applying: "applying",
    waiting_for_approval: "waiting_for_approval",
    approved: "approved",
    talent: "talent",
    rejected: "rejected"
  }

  module Delivery
    TYPES = [
      MessageReceivedNotification,
      TokenAcquiredNotification
    ].map(&:name).freeze

    METHODS = [DISABLED = 0, IMMEDIATE = 1, DIGEST = 2]
  end

  scope :beginner_quest_completed, -> { joins(:quests).where(quests: {type: "Quests::User", status: "done"}) }

  # [CLEARANCE] override email writing to allow nil but not two emails ""
  def self.normalize_email(email)
    if email.nil?
      email
    else
      email.to_s.downcase.gsub(/\s+/, "")
    end
  end
  # [CLEARANCE] end

  def self.valid_username?(new_username)
    new_username && new_username.length > 0 && new_username.match?(/^[a-z0-9]*$/)
  end

  def self.valid_email?(new_email)
    return false unless new_email && new_email.length > 0

    if ENV["EMAIL_REGEX_WITHOUT_ALIASES"] == "true"
      new_email.match?(/^(([^<>()\[\]\\.,;:\s@+"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/)
    else
      new_email.match?(/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/)
    end
  end

  def active_supporter?
    TalentSupporter.where(supporter_wallet_id: wallet_id).present?
  end

  def active_theme
    if theme_preference == "light"
      "light-body"
    else
      "dark-body"
    end
  end

  def admin?
    role == "admin"
  end

  def moderator?
    role == "moderator"
  end

  def admin_or_moderator?
    role.in?(%w[admin moderator])
  end

  def as_json(options = {})
    options[:except] ||= [:remember_token, :encrypted_password, :confirmation_token, :last_sign_in_at, :nounce, :email_confirmation_token]
    super(options)
  end

  def beginner_quest_completed?
    quests.where(type: "Quests::User", status: "done").any?
  end

  def confirm_email
    self.email_confirmed_at = Time.current
    save
  end

  def display_wallet_id
    return user_domain.domain if user_domain.present?

    wallet_id ? "#{wallet_id[0..10]}..." : ""
  end

  def has_unread_messages?
    messagee.unread.any?
  end

  def last_message_with(chat_user)
    result = Message.where(sender_id: id, receiver_id: chat_user.id)
      .or(Message.where(sender_id: chat_user.id, receiver_id: id)).order(id: :desc).limit(1)

    if result.length > 0
      result[0]
    end
  end

  def name
    display_name.present? ? display_name : username
  end

  def portfolio(including_self: true, invested_after: nil)
    return User.none unless wallet_id

    talent_supporters = TalentSupporter.where(supporter_wallet_id: wallet_id)
    talent_supporters = talent_supporters.where("last_time_bought_at > ?", invested_after) if invested_after

    token_contract_ids = talent_supporters.pluck(:talent_contract_id)
    supporting_users = User.joins(talent: :talent_token).where(talent_tokens: {contract_id: token_contract_ids})

    including_self ? supporting_users : supporting_users.where.not(id: id)
  end

  def prefers_digest_notification?(type)
    notification_preferences[type.name] == Delivery::DIGEST
  end

  def prefers_immediate_notification?(type)
    notification_preferences[type.name].nil? ||
      notification_preferences[type.name] == Delivery::IMMEDIATE
  end

  def profile_picture_url
    talent&.profile_picture_url
  end

  def public_displayable?
    profile_type == "talent" || profile_type == "approved"
  end

  def receiver_chat_id(chat_user)
    [id, chat_user.id].join("")
  end

  def sender_chat_id(chat_user)
    [id, chat_user.id].join("")
  end

  def supporters(including_self: true, invested_after: nil)
    return User.none unless talent&.talent_token&.deployed?

    talent_supporters = TalentSupporter.where(talent_contract_id: talent.talent_token.contract_id)
    talent_supporters = talent_supporters.where("last_time_bought_at > ?", invested_after) if invested_after

    supporters_wallet_ids = talent_supporters.pluck(:supporter_wallet_id)
    supporters = User.where(wallet_id: supporters_wallet_ids)

    including_self ? supporters : supporters.where.not(id: id)
  end

  def amount_invested_in(user)
    return 0 unless user.talent&.talent_token&.deployed?

    TalentSupporter.where(supporter_wallet_id: wallet_id, talent_contract_id: user.talent.talent_token.contract_id).sum { |ts| ts.amount.to_i }
  end

  def connected_with_since(other_user)
    supporter_data = TalentSupporter.find_by(supporter_wallet_id: wallet_id, talent_contract_id: other_user.talent&.talent_token&.contract_id)
    supporting_data = TalentSupporter.find_by(supporter_wallet_id: other_user.wallet_id, talent_contract_id: talent&.talent_token&.contract_id)
    follower_data = follows.find_by(follower: other_user)
    following_data = following.find_by(user: other_user)

    [
      supporter_data&.first_time_bought_at,
      supporting_data&.first_time_bought_at,
      follower_data&.created_at,
      following_data&.created_at
    ].compact.min
  end

  def talent?
    talent.present?
  end

  def valid_delete_account_token?(token)
    return false unless delete_account_token && delete_account_token_expires_at

    delete_account_token == token && delete_account_token_expires_at > Time.current
  end

  def approved_by
    return unless profile_type == "approved"

    profile_type_change = UserProfileTypeChange.find_by(new_profile_type: "approved", user: self)
    return unless profile_type_change

    profile_type_change.who_dunnit
  end

  private

  def email_and_password
    return if email.present? && encrypted_password.present?

    errors.add(:base, "The user doesn't respect the required login requirements")
  end

  def email_optional?
    true
  end

  def password_optional?
    true
  end

  def role_is_valid
    unless role.in?(VALID_ROLES)
      errors.add(:base, "The role #{role} isn't supported.")
    end
  end

  def username_is_valid
    errors.add(:base, "The username has invalid characters.") unless username.match?(/^[a-z0-9]*$/)
  end

  def email_and_credentials
    return if email.present? && (encrypted_password.present? || linkedin_id.present?)

    errors.add(:base, "The user doesn't respect the required login requirements")
  end

  def validate_notification_preferences
    valid = false

    if notification_preferences.is_a?(Hash)
      valid = notification_preferences.all? do |type, value|
        Delivery::TYPES.include?(type) && Delivery::METHODS.include?(value)
      end
    end

    if !valid
      errors.add(:notification_preferences, "Invalid notification preferences.")
    end
  end

  def touch_talent
    talent.touch if talent.present?
  end
end
