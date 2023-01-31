# Eth wrapper
module EthClient
  CHAIN_TO_NAME = {
    137 => "Polygon",
    44787 => "Alfajores",
    42220 => "Celo",
    80001 => "Mumbai"
  }

  CHAIN_TO_STAKING_ADDRESS = {
    137 => "0xE23104E89fF4c93A677136C4cBdFD2037B35BE67",
    44787 => "0x7eF9fe9e0A448cC2772706996a47d7e746a4Ce53",
    42220 => "0x5a6eF881E3707AAf7201dDb7c198fc94B4b12636",
    80001 => "0x15306066be334Aced273EB052f6bDA4C69Ee24A7"
  }

  module Celo
    Client = Eth::Client::Http.new("https://forno.celo.org/")
  end

  module Alfajores
    Client = Eth::Client::Http.new("https://alfajores-forno.celo-testnet.org/")
  end

  module Mumbai
    Client = Eth::Client::Http.new("https://matic-mumbai.chainstacklabs.com")
  end

  module Polygon
    Client = Eth::Client::Http.new("https://polygon-rpc.com/")
  end
end
