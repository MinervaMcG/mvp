require "rails_helper"
require "rake"

Rake.application.rake_require "tasks/partnerships"

RSpec.describe "partnerships:create_from_json" do
  let(:invite_code) { "invite_code" }
  let(:json_path) { "spec/fixtures/files/partnerships/utrust.json" }
  let(:max_uses) { 10 }
  let(:user) { create :user }
  let(:user_id) { user.id }

  let(:creator_class) { Invites::CreatePartnership }
  let(:creator) { instance_double(creator_class, call: partnership) }
  let(:partnership) { create :partnership }

  let(:partnership_params) do
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

    Rake::Task.define_task(:environment)
  end

  subject { Rake::Task["partnerships:create_from_json"] }

  it "initialises and calls the partnerships creator with the correct arguments" do
    subject.invoke(invite_code, json_path, max_uses, user_id)

    aggregate_failures do
      expect(creator_class)
        .to have_received(:new)
        .with(
          invite_code: invite_code,
          max_uses: max_uses,
          partnership_params: partnership_params,
          user: user
        )

      expect(creator)
        .to have_received(:call)
    end
  end

  context "when the JSON path does not end with '.json'" do
    it "does not initialise the partnerships creator" do
      subject.invoke(invite_code, "lib/tasks/partnerships/utrust", max_uses, user_id)

      expect(creator_class).not_to have_received(:new)
    end
  end

  context "when the user id is invalid" do
    it "does not initialise the partnerships creator" do
      subject.invoke(invite_code, json_path, max_uses, -1)

      expect(creator_class).not_to have_received(:new)
    end
  end
end
