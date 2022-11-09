require "rails_helper"

RSpec.describe TriggerChewyIndexUpdateJob, type: :job do
  let!(:talent) { create :talent }
  subject(:update_chewy_index) { described_class.perform_now }

  it "syncs new records on index" do
    TalentsIndex.purge!
    expect { update_chewy_index }.to change(TalentsIndex, :count).from(0).to(1)
  end
end
