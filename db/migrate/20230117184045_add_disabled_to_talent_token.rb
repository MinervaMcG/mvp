class AddDisabledToTalentToken < ActiveRecord::Migration[7.0]
  def change
    add_column :talent_tokens, :disabled, :boolean, default: false
  end
end
