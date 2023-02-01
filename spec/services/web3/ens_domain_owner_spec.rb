require "rails_helper"

RSpec.describe Web3::EnsDomainOwner do
  subject(:get_ens_domain_owner) { described_class.new(domain: domain).call }

  let(:domain) { "dinis.tal.community" }
  let(:contract_env) { "production" }
  let(:lambda_function_name) { "getENSDomainOwner" }

  let(:lambda_request_payload) do
    JSON.generate({domain: domain, env: contract_env})
  end

  let(:lambda_client_class) { Aws::Lambda::Client }
  let(:lambda_client) { instance_double(lambda_client_class) }

  before do
    allow(lambda_client_class).to receive(:new).and_return(lambda_client)
    allow(lambda_client).to receive(:invoke).and_return(lambda_response)
    ENV["CONTRACTS_ENV"] = contract_env
    ENV["ENS_DOMAIN_OWNER_LAMBDA_FUNCTION"] = lambda_function_name
  end

  let(:lambda_response) do
    OpenStruct.new(
      payload: OpenStruct.new(string: lambda_response_payload.to_json)
    )
  end

  let(:lambda_response_payload) do
    {
      statusCode: 200,
      body: {
        wallet: address
      }
    }
  end
  let(:address) { SecureRandom.hex }

  it "initializes the lambda client class" do
    get_ens_domain_owner

    expect(lambda_client_class).to have_received(:new).with(region: "eu-west-2")
  end

  it "calls the lambda client invoke method" do
    get_ens_domain_owner

    expect(lambda_client).to have_received(:invoke).with(
      function_name: lambda_function_name,
      invocation_type: "RequestResponse",
      log_type: "None",
      payload: lambda_request_payload
    )
  end

  it "returns the owner address" do
    expect(get_ens_domain_owner).to eq(address)
  end

  context "when the lambda response is not ok" do
    let(:lambda_response_payload) do
      {
        statusCode: 500,
        body: {
          error: "Etherscan is down"
        }
      }
    end

    before do
      allow(Rollbar).to receive(:error)
    end

    it "returns nil" do
      expect(get_ens_domain_owner).to eq(nil)
    end

    it "raises the error to Rollbar" do
      get_ens_domain_owner

      expect(Rollbar).to have_received(:error).with(
        "Unable to get owner address",
        domain: domain,
        env: contract_env,
        error: "Etherscan is down"
      )
    end
  end
end
