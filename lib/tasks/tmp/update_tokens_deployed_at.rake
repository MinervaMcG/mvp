namespace :tokens do
  task update_deployed_at: :environment do
    TalentToken.find_each do |talent_token|
      talent_token.update(deployed_at: talent_token.updated_at)
    end
  end
end
