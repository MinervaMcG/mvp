class AddTalDomainToUserDomains < ActiveRecord::Migration[7.0]
  def change
    add_column :user_domains, :tal_domain, :boolean, default: false
  end
end
