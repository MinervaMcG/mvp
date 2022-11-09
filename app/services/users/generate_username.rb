module Users
  class GenerateUsername
    def initialize(display_name:)
      @display_name = display_name.to_s
    end

    def call
      parameterized_name = display_name.parameterize(separator: "")
      return parameterized_name unless User.find_by(username: parameterized_name).present?

      "#{parameterized_name}#{(SecureRandom.random_number(9e5) + 1e5).to_i}"
    end

    private

    attr_reader :display_name
  end
end
