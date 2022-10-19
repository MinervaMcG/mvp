namespace :partnerships do
  desc "Create partnership from JSON file"
  # rake "partnerships:create_from_json[invite_code, spec/fixtures/files/partnerships/utrust.json, 1, 1]"
  task :create_from_json, [:invite_code, :json_path, :max_uses, :user_id] => :environment do |_t, args|
    json_path = args.json_path
    unless json_path.match?(/.?.json/)
      puts "Invalid JSON file"
      next
    end

    json_data = json_path.starts_with?("http") ? URI.parse(json_path).read : File.open(json_path).read
    data = JSON.parse(json_data)
    user = User.find_by(id: args.user_id)
    unless user
      puts "Invalid user ID"
      next
    end

    partnership = Invites::CreatePartnership.new(
      invite_code: args.invite_code,
      max_uses: args.max_uses,
      partnership_params: data.slice(*Invites::CreatePartnership::ATTRIBUTES + %w[banner_url logo_url]),
      user: user
    ).call

    puts "Successfully created partnership - #{partnership.name}"
  rescue Invites::CreatePartnership::Error => error
    puts "Could not create partnership: #{error.message}"
  end
end
