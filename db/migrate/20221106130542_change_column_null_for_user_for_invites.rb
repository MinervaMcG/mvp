class ChangeColumnNullForUserForInvites < ActiveRecord::Migration[6.1]
  def change
    change_column_null :invites, :user_id, true
  end
end
