namespace :users do
  desc "Set user as moderator"
  task :set_as_moderator, [:user_id] => :environment do |_t, args|
    user = User.find_by(id: args.user_id)
    raise "Invalid user" unless user

    user.role = "moderator"
    if user.save
      puts "#{user.username} (##{user.id}) was successfully set as a moderator!"
    else
      raise "Unable to set user as moderator: #{user.errors.full_messages.join(", ")}"
    end
  end

  desc "Set onboarded at"
  task set_onboarded_at: :environment do
    user_versions = PaperTrail::Version.where(item_type: "User")

    user_versions.where("object_changes ILIKE '%onboarding_complete%'").find_each do |user_version|
      user = User.find_by(id: user_version.item_id)
      next unless user

      user.update!(onboarded_at: user_version.created_at)
    end
  end
end
