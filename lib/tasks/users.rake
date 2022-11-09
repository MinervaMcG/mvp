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
end
