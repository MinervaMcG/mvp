require "rails_helper"

RSpec.describe "Sessions", type: :request do
  describe "#new" do
    subject(:root_request) { get root_path }

    context "when the request is not coming from a profile subdomain" do
      it "renders the login template" do
        root_request

        expect(response).to render_template("sessions/new")
      end
    end

    context "when the request is coming from a profile subdomain" do
      before do
        ENV["TAL_BASE_DOMAIN"] = "tal.community"
        host! "#{request_subdomain}.tal.community"
      end

      let(:request_subdomain) { "dinis" }

      context "when the subdomain belongs to a tal domain" do
        let(:user) { create :user }
        let!(:talent) { create :talent, user: user }
        let!(:tal_domain) { create :user_domain, tal_domain: true, domain: request_subdomain, user: user }

        it "renders the user profile" do
          root_request

          expect(response).to render_template("profiles/show")
        end
      end

      context "when the subdomain does not belong to a tal domain" do
        it "redirects to the main app" do
          root_request

          expect(response).to redirect_to("https://beta.talentprotocol.com/")
        end
      end
    end
  end
end
