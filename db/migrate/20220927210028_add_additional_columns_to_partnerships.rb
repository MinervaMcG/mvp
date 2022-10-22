class AddAdditionalColumnsToPartnerships < ActiveRecord::Migration[6.1]
  def change
    add_column :partnerships, :banner_data, :text
    add_column :partnerships, :button_name, :string
    add_column :partnerships, :button_url, :string
    add_column :partnerships, :location, :string
  end
end
