module Web3
  class VerifyWallet
    def initialize(wallet, signature, signature_data)
      @wallet = wallet
      @signature = signature
      @signature_data = signature_data
    end

    def call
      decoded_wallet = eth_sig.getSignerAccount(signature_data, signature)

      wallet.downcase == decoded_wallet.downcase
    end

    private

    attr_reader :wallet, :signature, :signature_data

    def eth_sig
      @eth_sig ||= Web3::EthSigSchmooze.new(__dir__)
    end
  end
end
