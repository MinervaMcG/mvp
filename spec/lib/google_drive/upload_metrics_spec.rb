require "google_drive/upload_metrics"
require "rails_helper"

RSpec.describe GoogleDrive::UploadMetrics do
  let(:upload_metrics) { described_class.new(daily_metric).call }

  let(:daily_metric) { create :daily_metric, date: Date.new }

  let(:google_drive_class) { GoogleDrive::Session }
  let(:google_drive) { instance_double(google_drive_class) }

  let(:spreadsheet) { instance_double(GoogleDrive::Spreadsheet) }
  let(:worksheet) { instance_double(GoogleDrive::Worksheet, insert_rows: true, save: true) }

  let(:google_drive_account_json) { {} }

  before do
    allow(google_drive_class).to receive(:from_service_account_key).and_return(google_drive)
    allow(google_drive).to receive(:spreadsheet_by_key).and_return(spreadsheet)
    allow(spreadsheet).to receive(:worksheet_by_title).and_return(worksheet)
    ENV["GOOGLE_SERVICE_ACCOUNT_JSON"] = google_drive_account_json.to_json
  end

  it "initializes a google drive session" do
    upload_metrics

    expect(google_drive_class).to have_received(:from_service_account_key)
  end

  it "fetches the correct spreadsheet" do
    upload_metrics

    expect(google_drive).to have_received(:spreadsheet_by_key).with(
      described_class::METRICS_SHEET_ID
    )
  end

  it "fetches the correct worksheet" do
    upload_metrics

    expect(spreadsheet).to have_received(:worksheet_by_title).with(
      "Daily Data"
    )
  end

  it "inserts and saves the data in the worksheet" do
    upload_metrics

    expect(worksheet).to have_received(:insert_rows)
    expect(worksheet).to have_received(:save)
  end
end
