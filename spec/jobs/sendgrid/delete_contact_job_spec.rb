require "rails_helper"

RSpec.describe Sendgrid::DeleteContactJob, type: :job do
  include ActiveJob::TestHelper

  let(:email) { "user-one@gmail.com" }

  let(:delete_class) { Sendgrid::Contacts::Delete }
  let(:delete) { instance_double(delete_class, call: nil) }

  before do
    allow(delete_class).to receive(:new).and_return(delete)
  end

  subject { described_class.new }

  describe "#perform" do
    it "initializes and calls the SendGrid contacts delete with the email" do
      subject.perform(email)

      aggregate_failures do
        expect(delete_class).to have_received(:new).with(emails: email)
        expect(delete).to have_received(:call)
      end
    end
  end
end
