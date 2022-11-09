class Invite < ApplicationRecord
  belongs_to :partnership, optional: true
  belongs_to :user, optional: true

  has_many :invitees, class_name: "User", inverse_of: :invited

  has_one :partnership_invitee, class_name: "Partnership", inverse_of: :invited

  validate :partnership_or_user
  validates :code, presence: true

  INVITE_CODE_SIZE = 8

  scope :common, -> { where(talent_invite: false) }

  def active?
    max_uses.nil? || uses < max_uses
  end

  def invites_left
    if max_uses.nil?
      uses > 0 ? uses : 1
    else
      max_uses - uses
    end
  end

  def name
    return partnership.name if partnership
    return user.name if user
  end

  def profile_picture_url
    return partnership.logo_url if partnership
    return user.profile_picture_url if user
  end

  def self.generate_code
    SecureRandom.hex(INVITE_CODE_SIZE)
  end

  private

  def partnership_or_user
    errors.add(:base, "Partnership and user can't both be present") if partnership && user
    errors.add(:base, "Partnership or user can't both be blank") unless partnership || user
  end
end
