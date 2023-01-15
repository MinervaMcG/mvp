class SyncWithPersonaJob < ApplicationJob
  queue_as :default

  def perform
    service = WithPersona::FetchInquiries.new
    service.call
  end
end
