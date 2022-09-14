class SetupNextRaceJob < ApplicationJob
  queue_as :default

  def perform
    service = Races::FinishActiveRace.new
    service.call
  end
end
