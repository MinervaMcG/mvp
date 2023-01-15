# frozen_string_literal: true

module Tasks
  class Verified < Task
    def title
      "Verify your profile"
    end

    def description
      "Click on the Verify button in your profile and get verified"
    end

    def link
      "/u/#{quest.user.username}"
    end
  end
end
