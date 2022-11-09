class Erc20Token < ApplicationRecord
  include Token

  def erc_20?
    true
  end

  def erc_721?
    false
  end
end
