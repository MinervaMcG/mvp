namespace :partnerships do
  desc "Create partnership from JSON file"
  # rake "partnerships:create_from_json[spec/fixtures/files/partnerships/utrust.json, 3]"
  task :create_from_json, [:json_path, :max_uses] => :environment do |_t, args|
    json_path = args.json_path
    unless json_path.match?(/.?.json/)
      puts "Invalid JSON file"
      next
    end

    max_uses = args.max_uses.to_i
    if max_uses.zero?
      puts "Invalid max uses"
      next
    end

    json_data = json_path.starts_with?("http") ? URI.parse(json_path).read : File.read(json_path)
    data = JSON.parse(json_data)
    params = data.slice(*Partnerships::Create::ATTRIBUTES + %w[banner_url logo_url])
    partnership = Partnerships::Create.new(max_uses: max_uses, params: params).call

    puts "Successfully created partnership - #{partnership.name}"
  rescue Partnerships::Create::Error => error
    puts "Could not create partnership: #{error.message}"
  end
end
