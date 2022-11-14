require "rails_helper"

RSpec.describe Users::Create do
  include ActiveJob::TestHelper

  subject(:create_user) { described_class.new.call(user_creation_params) }

  let(:user_creation_params) {
    {
      email: email,
      password: password,
      username: username,
      invite_code: invite_code
    }
  }

  let(:email) { "test@talentprotocol.com" }
  let(:password) { "password" }
  let(:username) { "test" }
  let(:invite_code) { invite.code }

  let(:user) { create :user, username: "jack" }
  let!(:invite) { create :invite, user: user }

  let(:notification_creator_class) { CreateNotification }
  let(:notification_creator) { instance_double(notification_creator_class, call: true) }

  before do
    allow(notification_creator_class).to receive(:new).and_return(notification_creator)
  end

  context "when a valid invite is provided" do
    it "creates a new user" do
      result = create_user
      user = result[:user]

      expect(result[:success]).to be(true)
      expect(user).to be_persisted
      expect(user.email).to eq(email)
      expect(user.email_confirmation_token).not_to be_nil
      expect(user.invited).to eq(invite)
      expect(user.password).not_to be_nil
      expect(user.role).to eq("basic")
      expect(user.theme_preference).to eq("light")
      expect(user.username).to eq(username)
    end

    context "when a display name is provided" do
      let(:display_name) { "Jack Smith" }

      let(:user_creation_params) do
        super().tap { |params| params[:display_name] = display_name }
      end

      it "persists the display name" do
        result = create_user

        expect(result[:user].display_name).to eq(display_name)
      end
    end

    context "when a theme preference is provided" do
      let(:theme_preference) { "dark" }

      let(:user_creation_params) do
        super().tap { |params| params[:theme_preference] = theme_preference }
      end

      it "persists the theme preference" do
        result = create_user

        expect(result[:user].theme_preference).to eq(theme_preference)
      end
    end

    context "when a LinkedIn id is provided" do
      let(:linkedin_id) { SecureRandom.hex(8) }
      let(:password) { nil }

      let(:user_creation_params) do
        super().tap { |params| params[:linkedin_id] = linkedin_id }
      end

      it "persists the LinkedIn id" do
        result = create_user
        user = result[:user]

        expect(user.linkedin_id).to eq(linkedin_id)
        expect(user.password).to be_nil
      end
    end

    it "initializes and calls the notification creator with the correct arguments" do
      result = create_user

      aggregate_failures do
        expect(notification_creator_class).to have_received(:new)

        expect(notification_creator).to have_received(:call)
          .with(
            recipient: invite.user,
            source_id: result[:user].id,
            type: InviteUsedNotification
          )
      end
    end
  end

  context "when it is a talent invite" do
    let(:invite) { create(:invite, user: user, talent_invite: true) }

    it "creates a new user with talent as profile type" do
      create_user

      user = User.find_by(email: email)

      expect(user.profile_type).to eq("talent")
    end

    context "when the talent invite passed is associated with a partnership" do
      let!(:invite) { create :invite, partnership: partnership, code: "core-team", talent_invite: true, user: nil }
      let!(:partnership) { create :partnership, name: "Talent Protocol Core Team", description: "Team building Talent Protocol." }

      it "creates a new discovery row" do
        create_user

        created_discovery_row = DiscoveryRow.last

        aggregate_failures do
          expect(created_discovery_row.partnership).to eq partnership
          expect(created_discovery_row.title).to eq partnership.name
          expect(created_discovery_row.description).to eq partnership.description
        end
      end

      it "creates the discovery row with the correct arguments" do
        expect { create_user }.to change(DiscoveryRow, :count).from(0).to(1)
      end

      it "creates a new hidden tag" do
        expect { create_user }.to change(Tag.where(hidden: true), :count).from(0).to(1)
      end

      it "creates the tag the correct arguments" do
        create_user

        created_tag = Tag.last

        aggregate_failures do
          expect(created_tag.description).to eq invite_code
          expect(created_tag.hidden).to eq true
        end
      end

      it "associates the new tag with the user and the discovery row" do
        create_user

        created_user = User.last
        created_discovery_row = DiscoveryRow.last
        created_tag = Tag.last

        aggregate_failures do
          expect(created_user.tags).to include created_tag
          expect(created_discovery_row.tags).to include created_tag
        end
      end

      context "when the discovery row already exists" do
        let!(:discovery_row) { create :discovery_row, partnership: partnership }

        it "does not create a new discovery row" do
          expect { create_user }.not_to change(DiscoveryRow, :count)
        end

        it "associates the new tag with existing discovery row" do
          create_user

          created_tag = Tag.last

          expect(discovery_row.tags).to include created_tag
        end
      end

      context "when the hidden tag already exists" do
        let!(:tag) { create :tag, description: invite_code, hidden: true }

        it "does not create a new tag" do
          expect { create_user }.not_to change(Tag.where(hidden: true), :count)
        end

        it "associates the existing tag with the user and the discovery row" do
          create_user

          created_user = User.last
          created_discovery_row = DiscoveryRow.last

          aggregate_failures do
            expect(created_user.tags).to include tag
            expect(created_discovery_row.tags).to include tag
          end
        end
      end
    end
  end
end
