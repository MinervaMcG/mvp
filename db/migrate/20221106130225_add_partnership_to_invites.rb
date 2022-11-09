class AddPartnershipToInvites < ActiveRecord::Migration[6.1]
  def change
    add_reference :invites, :partnership, foreign_key: true, index: true
  end
end
