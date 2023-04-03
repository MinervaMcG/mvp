require "rails_helper"

RSpec.describe Web3::SponsorshipSync do
  let(:eth_client_class) { Eth::Client }
  let(:provider) { instance_double(eth_client_class) }

  subject(:sponsorship_sync) { described_class.new }

  before do
    allow(eth_client_class).to receive(:create).and_return(provider)
    allow(provider).to receive(:eth_get_transaction_receipt).and_return(
      {"jsonrpc" => "2.0",
       "id" => 1,
       "result" =>
         {"blockHash" => "0x8c789dbe728f26f623dd234e0b9f24f5bf7a5ea36a40d07abee3b6ebd1843d1d",
          "blockNumber" => "0xff6e1d",
          "contractAddress" => nil,
          "cumulativeGasUsed" => "0x24e513",
          "from" => "0x33041027dd8f4dc82b6e825fb37adf8f15d44053",
          "gasUsed" => "0x234e2",
          "logs" =>
           [{"address" => "0x874069fa1eb16d44d622f2e0ca25eea172369bc1",
             "topics" => ["0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef", "0x00000000000000000000000033041027dd8f4dc82b6e825fb37adf8f15d44053", "0x000000000000000000000000fb32c3635fba97046e83804fb903254507ae32a4"],
             "data" => "0x0000000000000000000000000000000000000000000000001bc16d674ec80000",
             "blockNumber" => "0xff6e1d",
             "transactionHash" => "0x9edaf3a5e15695457319969406024b59fd156a0b5433c4a5bbfe0444572b3561",
             "transactionIndex" => "0x2",
             "blockHash" => "0x8c789dbe728f26f623dd234e0b9f24f5bf7a5ea36a40d07abee3b6ebd1843d1d",
             "logIndex" => "0x31",
             "removed" => false},
             {"address" => "0xfb32c3635fba97046e83804fb903254507ae32a4",
              "topics" =>
               ["0x731fa8c1fe722772dcb0c9b11e0a53af551dd3d2ac3f2c1e0892eee5d118e59d",
                 "0x00000000000000000000000033041027dd8f4dc82b6e825fb37adf8f15d44053",
                 "0x00000000000000000000000033041027dd8f4dc82b6e825fb37adf8f15d44053",
                 "0x000000000000000000000000874069fa1eb16d44d622f2e0ca25eea172369bc1"],
              "data" =>
               "0x0000000000000000000000000000000000000000000000001bc16d674ec80000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000046355534400000000000000000000000000000000000000000000000000000000",
              "blockNumber" => "0xff6e1d",
              "transactionHash" => "0x9edaf3a5e15695457319969406024b59fd156a0b5433c4a5bbfe0444572b3561",
              "transactionIndex" => "0x2",
              "blockHash" => "0x8c789dbe728f26f623dd234e0b9f24f5bf7a5ea36a40d07abee3b6ebd1843d1d",
              "logIndex" => "0x32",
              "removed" => false}],
          "logsBloom" =>
           "0x00000000000000000000000004000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000400000100000000000000008000000000000000000000000000000000000000000040000000001000000000010000000000000000800000040000000000000000000400000000000000000000000000000000000000000004000000000000000020000000000000000000000000000800000000006000000000800000000000000000000000000000000001000000000000000000000080000000000000000000000000000000000020000000000000000",
          "status" => "0x1",
          "to" => "0xfb32c3635fba97046e83804fb903254507ae32a4",
          "transactionHash" => "0x9edaf3a5e15695457319969406024b59fd156a0b5433c4a5bbfe0444572b3561",
          "transactionIndex" => "0x2",
          "type" => "0x2"}}
    )
    allow(provider).to receive(:chain_id).and_return(44787)
  end

  it "creates a new daily record with the correct arguments" do
    sponsorship_sync.call("0x9edaf3a5e15695457319969406024b59fd156a0b5433c4a5bbfe0444572b3561")

    sponsorship = Sponsorship.last

    aggregate_failures do
      expect(sponsorship.sponsor).to eq "0x33041027dd8f4dc82b6e825fb37adf8f15d44053"
      expect(sponsorship.talent).to eq "0x33041027dd8f4dc82b6e825fb37adf8f15d44053"
      expect(sponsorship.amount).to eq 2000000000000000000
      expect(sponsorship.token).to eq "0x874069fa1eb16d44d622f2e0ca25eea172369bc1"
      expect(sponsorship.symbol).to eq "cUSD"
      expect(sponsorship.tx_hash).to eq "0x9edaf3a5e15695457319969406024b59fd156a0b5433c4a5bbfe0444572b3561"
      expect(sponsorship.chain_id).to eq 44787
    end
  end
end
