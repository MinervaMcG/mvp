class WhitelistUserJob < ApplicationJob
  queue_as :default

  def perform(user_id:, level:)
    return if ENV["ENABLE_TALENT_MATES"] != "enable"

    user = User.find(user_id)

    service = Web3::WhitelistTalentMate.new
    service.call(user: user, level: level)
  end
end
