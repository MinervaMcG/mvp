namespace :apply_launch_token_task do
  task update: :environment do
    User.where.not(profile_type: "supporter").find_each do |user|
      Tasks::Update.new.call(type: "Tasks::ApplyTokenLaunch", user: user)
    end
  end
end
