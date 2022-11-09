require "rails_helper"

RSpec.describe Erc721Token, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    subject { build :erc721_token }

    it { is_expected.to validate_presence_of(:address) }
  end

  describe "#erc_20?" do
    subject { build :erc721_token }

    it "returns false" do
      expect(subject.erc_20?).to eq false
    end
  end

  describe "#erc_721?" do
    subject { build :erc721_token }

    it "returns true" do
      expect(subject.erc_721?).to eq true
    end
  end

  describe "#token_description" do
    let(:metadata) { {description: "Test Token"} }
    subject { build :erc721_token, metadata: metadata, description: description }

    context "when the token has a description" do
      let(:description) { "DINIS TOKEN" }

      it "returns the stored description" do
        expect(subject.token_description).to eq description
      end
    end

    context "when the token is empty" do
      let(:description) { "" }

      it "returns the metadata description" do
        expect(subject.token_description).to eq "Test Token"
      end
    end
  end

  describe "#token_name" do
    let(:metadata) { {name: "Test"} }
    subject { build :erc721_token, metadata: metadata, name: name }

    context "when the token has a name" do
      let(:name) { "DINIS" }

      it "returns the stored name" do
        expect(subject.token_name).to eq name
      end
    end

    context "when the token is empty" do
      let(:name) { "" }

      it "returns the metadata name" do
        expect(subject.token_name).to eq "Test"
      end
    end
  end

  describe "#token_image" do
    let(:metadata) { {image: image} }
    let(:image) { "ipfs://asdasdhaihsdiansodas.png" }
    let(:external_image_url) { "https://image-path.png" }
    subject { build :erc721_token, metadata: metadata, external_image_url: external_image_url }

    context "when the token has the image url stored" do
      it "returns the path of the stored image" do
        expect(subject.token_image).to eq external_image_url
      end
    end

    context "when the token does not have an image attached" do
      let(:external_image_url) { nil }

      context "when the image is from ipfs" do
        let(:image) { "ipfs://asdasdhaihsdiansodas.png" }

        it "returns the ipfs gateway path" do
          expect(subject.token_image).to eq "https://ipfs.io/ipfs/asdasdhaihsdiansodas.png"
        end
      end

      context "when the image is not from ipfs" do
        let(:image) { "https://host.images/asdasdhaihsdiansodas.png" }

        it "returns nil" do
          expect(subject.token_image).to eq nil
        end
      end
    end
  end
end
