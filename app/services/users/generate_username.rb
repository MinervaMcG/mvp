module Users
  class GenerateUsername
    def initialize(display_name:)
      @display_name = display_name.to_s
    end

    def call
      parameterized_name = display_name.parameterize(separator: "")
      return random_sequence.to_s if parameterized_name.blank?

      return parameterized_name unless User.find_by(username: parameterized_name).present?

      "#{parameterized_name}#{random_sequence}"
    end

    private

    attr_reader :display_name

    def random_sequence
      @random_sequence ||= (SecureRandom.random_number(9e5) + 1e5).to_i
    end
  end
end
