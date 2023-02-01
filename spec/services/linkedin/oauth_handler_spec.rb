require "rails_helper"

RSpec.describe Linkedin::OauthHandler do
  subject(:handle_linkedin_oauth) do
    described_class.new(code: code).call
  end

  let(:client) do
    instance_double(
      client_class,
      retrieve_access_token: retrieve_access_token_response,
      retrieve_email_address: retrieve_email_address_response,
      retrieve_lite_profile: retrieve_lite_profile_response
    )
  end

  let(:client_class) { Linkedin::Client }

  let(:retrieve_access_token_response) do
    OpenStruct.new(
      body: {
        "access_token" => access_token
      }.to_json,
      success?: true
    )
  end

  let(:retrieve_email_address_response) do
    OpenStruct.new(
      body: {
        "elements" => [
          {
            "handle~" => {
              "emailAddress" => "john-doe@gmail.com"
            },
            "handle" => "urn:li:emailAddress:98231232197"
          }
        ]
      }.to_json,
      success?: true
    )
  end

  let(:retrieve_lite_profile_response) do
    OpenStruct.new(
      body: {
        "id" => linkedin_id,
        "localizedFirstName" => localized_first_name,
        "localizedLastName" => "Doe",
        "profilePicture" => profile_picture
      }.to_json,
      success?: true
    )
  end

  let(:linkedin_id) { "8U-184SDzjs" }

  let(:localized_first_name) { "John" }

  let(:profile_picture) do
    {
      "displayImage~" => {
        "elements" => [
          {
            "identifiers" => [
              {
                "identifier" => "profile_picture_url"
              }
            ]
          }
        ]
      }
    }
  end

  let(:access_token) { "access_token" }
  let(:code) { "code" }

  let(:creator_class) { Users::Create }
  let(:creator) { instance_double(creator_class, call: result) }
  let(:result) { {success: true, user: user} }
  let(:user) { create :user, talent: talent }
  let(:talent) { create :talent }

  let(:chunked_io) do
    instance_double(Down::ChunkedIO, close: true, eof?: true, read: true, rewind: true)
  end

  before do
    allow(client_class).to receive(:new).and_return(client)
    allow(creator_class).to receive(:new).and_return(creator)
    allow(SecureRandom).to receive(:random_number).and_return(314835)
    allow(Down).to receive(:open).and_return(chunked_io)
    allow(talent).to receive(:profile_picture=)
    allow(talent).to receive(:save!)
  end

  describe "#call" do
    it "calls #retrieve_access_token on the client with the code" do
      handle_linkedin_oauth

      expect(client).to have_received(:retrieve_access_token).with(code)
    end

    context "when the client returns an unsuccessful response when retrieving an access token" do
      let(:retrieve_access_token_response) do
        OpenStruct.new(success?: false)
      end

      it "returns a unsuccessful response" do
        expect(handle_linkedin_oauth).to eq({success: false})
      end
    end

    it "calls #retrieve_email_address on the client with the access token" do
      handle_linkedin_oauth

      expect(client).to have_received(:retrieve_email_address).with(access_token)
    end

    context "when the client returns an unsuccessful response when retrieving the email address" do
      let(:retrieve_email_address_response) do
        OpenStruct.new(success?: false)
      end

      it "returns a unsuccessful response" do
        expect(handle_linkedin_oauth).to eq({success: false})
      end
    end

    context "when the user creator class raises an error" do
      let(:error) { StandardError.new }

      before do
        allow(creator).to receive(:call).and_raise(error)
        allow(Rollbar).to receive(:error)
      end

      it "returns an unsuccessful response" do
        expect(handle_linkedin_oauth).to eq({success: false})
      end

      it "raises the error to Rollbar with extra data" do
        handle_linkedin_oauth

        expect(Rollbar).to have_received(:error).with(
          error,
          email_address: "john-doe@gmail.com",
          display_name: "John Doe",
          username: "johndoe",
          linkedin_id: "8U-184SDzjs",
          lite_profile_request_body: JSON.parse(retrieve_lite_profile_response.body),
          email_address_request_body: JSON.parse(retrieve_email_address_response.body)
        )
      end
    end

    it "calls #retrieve_lite_profile on the client with the access token" do
      handle_linkedin_oauth

      expect(client).to have_received(:retrieve_lite_profile).with(access_token)
    end

    context "when there is a user with the email address" do
      before do
        allow(User).to receive(:find_by).with(email: "john-doe@gmail.com").and_return(user)
      end

      it_behaves_like "a profile picture uploader"

      it "updates the user linked_in" do
        handle_linkedin_oauth

        expect(user.reload.linkedin_id).to eq("8U-184SDzjs")
      end
    end

    context "when there is no user with the email address" do
      context "when the client returns an unsuccessful response when retrieving the lite profile" do
        let(:retrieve_lite_profile_response) do
          OpenStruct.new(success?: false)
        end

        it "returns a unsuccessful response" do
          expect(handle_linkedin_oauth).to eq({success: false})
        end
      end

      it "initialises and calls the user creator with the correct arguments" do
        handle_linkedin_oauth

        aggregate_failures do
          expect(creator_class).to have_received(:new)

          expect(creator).to have_received(:call)
            .with(
              display_name: "John Doe",
              email: "john-doe@gmail.com",
              linkedin_id: "8U-184SDzjs",
              password: nil,
              username: "johndoe"
            )
        end
      end

      context "when the username is taken by another user" do
        before do
          create :user, username: "johndoe"
        end

        it "initialises and calls the user creator with a username and a random six digit number" do
          handle_linkedin_oauth

          aggregate_failures do
            expect(creator_class).to have_received(:new)

            expect(creator).to have_received(:call)
              .with(
                display_name: "John Doe",
                email: "john-doe@gmail.com",
                linkedin_id: "8U-184SDzjs",
                password: nil,
                username: "johndoe414835"
              )
          end
        end
      end

      context "when the LinkedIn name contains special characters" do
        let(:localized_first_name) { "Rúben|" }

        it "initialises and calls the user creator with a username without special characters" do
          handle_linkedin_oauth

          aggregate_failures do
            expect(creator_class).to have_received(:new)

            expect(creator).to have_received(:call)
              .with(
                display_name: "Rúben| Doe",
                email: "john-doe@gmail.com",
                linkedin_id: "8U-184SDzjs",
                password: nil,
                username: "rubendoe"
              )
          end
        end
      end

      it "enqueues a job to add user to Mailerlite" do
        handle_linkedin_oauth

        expect(AddUsersToMailerliteJob).to have_been_enqueued.with(user.id)
      end

      it_behaves_like "a profile picture uploader"

      it "returns a success result with the user" do
        expect(handle_linkedin_oauth).to eq({success: true, user: user})
      end

      context "when the user creator returns an unsucessful response" do
        let(:result) { {error: "Error", success: false} }

        it "returns an unsuccessful result" do
          expect(handle_linkedin_oauth).to eq({success: false})
        end
      end
    end
  end
end
