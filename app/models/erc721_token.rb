class Erc721Token < ApplicationRecord
  include Token

  enum nft_type: {
    poap: "poap",
    nft: "nft"
  }
end
