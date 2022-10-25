class TriggerChewyIndexUpdateJob < ApplicationJob
  queue_as :default

  def perform()
    Chewy::Index::Syncer.new(TalentsIndex).perform
  end
end
