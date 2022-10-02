class Erc20Token < ApplicationRecord
  include Token

  def erc_20?
    true
  end
end
