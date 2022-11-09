require "rails_helper"
require "rake"

RSpec.describe "partnerships:create_from_json" do
  include_context "rake"

  let(:json_path) { "spec/fixtures/files/partnerships/utrust.json" }
  let(:max_uses) { 3 }

  let(:creator_class) { Partnerships::Create }
  let(:creator) { instance_double(creator_class, call: partnership) }
  let(:partnership) { create :partnership }

  let(:params) do
    {
      "banner_url" => "https://c0.wallpaperflare.com/preview/931/255/701/banner-digital-graphics-lion.jpg",
      "button_name" => "Buy $UTK",
      "button_url" => "https://utrust.com/",
      "description" =>
      "Utrust is a seamless integration that gives e-commerce businesses the power to accept digital currencies - and get all the benefits you can't with just traditional payment methods.",
      "location" => "Lisboa, Portugal",
      "logo_url" => "https://cryptogeek.info/upload/content/5f75e7f1385ab.png",
      "name" => "Utrust",
      "twitter_url" => "https://twitter.com/utrust",
      "website_url" => "https://utrust.com/"
    }
  end

  before do
    allow(creator_class).to receive(:new).and_return(creator)
  end

  it "initialises and calls the partnerships creator with the correct arguments" do
    subject.invoke(json_path, max_uses)

    aggregate_failures do
      expect(creator_class).to have_received(:new).with(max_uses: max_uses, params: params)
      expect(creator).to have_received(:call)
    end
  end

  context "when the JSON path does not end with '.json'" do
    let(:json_path) { "spec/fixtures/files/partnerships/utrust" }

    it "does not initialise the partnerships creator" do
      subject.invoke(json_path, max_uses)

      expect(creator_class).not_to have_received(:new)
    end
  end

  context "when max uses is a word" do
    let(:max_uses) { "max_uses" }

    it "does not initialise the partnerships creator" do
      subject.invoke(json_path, max_uses)

      expect(creator_class).not_to have_received(:new)
    end
  end

  context "when max uses is zero" do
    let(:max_uses) { 0 }

    it "does not initialise the partnerships creator" do
      subject.invoke(json_path, max_uses)

      expect(creator_class).not_to have_received(:new)
    end
  end
end
