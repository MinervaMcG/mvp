require "rails_helper"

RSpec.shared_examples "a discovery row get endpoint request" do
  context "when the discovery row passed exists" do
    let!(:discovery_row) { create :discovery_row }
    let(:slug) { discovery_row.slug }

    it "returns a successful response" do
      get_discovery_row

      expect(response).to have_http_status(:ok)
    end

    it "assigns the correct objects to be passed to the view" do
      get_discovery_row

      expect(assigns(:discovery_row)).to eq(DiscoveryRowBlueprint.render_as_json(discovery_row, view: :normal))
    end
  end

  context "when the discovery row passed does not exist" do
    let(:slug) { "random" }

    it "returns a not found response" do
      get_discovery_row

      expect(response).to have_http_status(:not_found)
    end
  end
end

RSpec.describe "Discovery rows", type: :request do
  describe "#show" do
    subject(:get_discovery_row) { get discovery_path(slug: slug, as: current_user) }

    context "when the current user is nil" do
      let(:current_user) { nil }

      it_behaves_like "a discovery row get endpoint request"
    end

    context "when the current user is passed" do
      let(:current_user) { create :user }

      it_behaves_like "a discovery row get endpoint request"
    end
  end
end
