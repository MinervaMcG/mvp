namespace :tokens do
  task migrate_dev: :environment do
    Token.update_all(chain_id: 44787)
  end

  task migrate_prod: :environment do
    Token.update_all(chain_id: 42220)
  end
end
