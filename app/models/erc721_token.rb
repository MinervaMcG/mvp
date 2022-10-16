class Erc721Token < ApplicationRecord
  include Token

  enum nft_type: {
    poap: "poap",
    nft: "nft"
  }

  def erc_20?
    false
  end

  def token_name
    return name if name.present?

    metadata.present? ? metadata["name"] : nil
  end

  def token_description
    return description if description.present?

    metadata.present? ? metadata["description"] : nil
  end

  def token_image
    return token_image_url if token_image_url

    metadata.present? ? ipfs_image(metadata["image"]) : nil
  end

  private

  def ipfs_image(ipfs_url)
    return nil unless ipfs_url&.include?("ipfs://")

    "https://ipfs.io/ipfs/" + ipfs_url.gsub("ipfs://", "").gsub("ipfs/", "")
  end
end
