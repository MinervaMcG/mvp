class ChangeTokensToTalentTokens < ActiveRecord::Migration[6.1]
  def change
    rename_table :tokens, :talent_tokens
  end
end
