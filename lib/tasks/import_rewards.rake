require "csv"

namespace :rewards do
  # rake "rewards:import[https://gist.githubusercontent.com/RubenSousaDinis/f16d127003fb29e14bd98815c918c480/raw/7a4c2f6581237e7fb5545d62bca6dfc11c7e0b1d/template.csv]"
  task :import, [:csv_file_path] => :environment do |_t, args|
    csv_path = args.csv_file_path
    unless csv_path.match?(/.?.csv/)
      raise "Invalid CSV file"
    end

    csv_data = csv_path.starts_with?("http") ? URI.parse(csv_path).read : File.open(csv_path).read

    invalid_rewards = {}
    row_line = 1
    rows = CSV.parse(csv_data, {encoding: "UTF-8", headers: true, header_converters: :symbol, converters: :all})
    rows_count = rows.count
    rows.each do |reward|
      messages = []

      user = User.find_by(username: reward[:username])
      unless user
        messages << "User #{reward[:username]} not found"
      end

      creator = User.find_by(username: reward[:creator_username])
      unless creator
        messages << "Creator #{reward[:creator_username]} not found"
      end

      unless reward[:identifier]
        messages << "Identifier field is required"
      end

      unless reward[:reason]
        messages << "Reason field is required"
      end

      category = reward[:category].downcase
      unless reward[:category]
        messages << "Category field is required"
      end

      unless Reward.categories.value?(category)
        messages << "Inavlid category #{reward[:category]}. Valid values: #{Reward.categories.values.join(", ")}"
      end

      unless reward[:amount_in_tal]
        messages << "Amount field is required"
      end

      if messages.empty?
        reward = Reward.create(
          identifier: reward[:identifier],
          user: user,
          creator: creator,
          category: reward[:category].downcase,
          reason: reward[:reason],
          amount: reward[:amount_in_tal],
          imported: true
        )

        messages += reward.errors.full_messages if reward.errors.full_messages.any?
      end

      if messages.any?
        invalid_rewards[row_line] = messages
      else
        puts "Imported reward #{row_line} of #{rows_count}"
      end

      row_line += 1
    end

    if invalid_rewards.any?
      puts "##{invalid_rewards.count} - Invalid rewards not imported"
      puts invalid_rewards.inspect
    else
      puts "All imported successfully"
    end
  end
end
