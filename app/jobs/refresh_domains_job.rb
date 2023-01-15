class RefreshDomainsJob < ApplicationJob
  queue_as :low

  def perform(user_id)
    user = User.find(user_id)

    Web3::RefreshDomains.new(user: user).call
  end
end
