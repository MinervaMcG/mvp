class AddWithPersonaIdToTalents < ActiveRecord::Migration[6.1]
  def change
    add_column :talent, :with_persona_id, :string
  end
end
