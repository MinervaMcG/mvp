class Erc721Token < ApplicationRecord
  include Token

  enum nft_type: {
    poap: "poap",
    nft: "nft"
  }

  def erc_20?
    false
  end
end
