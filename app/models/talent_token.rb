class TalentToken < ApplicationRecord
  has_paper_trail

  belongs_to :talent
  validates :ticker, length: {in: 3..8}, if: :ticker_exists?
  validates :ticker, uniqueness: {message: "already taken."}, if: :ticker_exists?

  # Elasticsearch index update
  update_index("talents") { self }

  TAL_VALUE = 2
  TAL_DECIMALS = 10**18
  TAL_VALUE_IN_USD = 0.02
  TALENT_TOKEN_VALUE_IN_USD = 0.1

  scope :deployed, -> { where.not(deployed_at: nil) }
  scope :on_chain, ->(chain_id) { where(chain_id: chain_id) }

  CHAIN_INFO = {
    137 => "POLYGON (Matic)",
    42220 => "CELO",
    44787 => "CELO (Alfajores)",
    80001 => "POLYGON (Mumbai)"
  }

  def display_ticker
    "$#{ticker}"
  end

  def chain_name
    CHAIN_INFO[chain_id]
  end

  private

  def ticker_exists?
    ticker.present?
  end
end
