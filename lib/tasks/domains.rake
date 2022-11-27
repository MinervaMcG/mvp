namespace :domains do
  task refresh: :environment do
    User.where.not(wallet_id: nil).order(:id).find_each do |user|
      puts user.id
      RefreshDomainsJob.perform_later(user.id)
    end
  end
end
