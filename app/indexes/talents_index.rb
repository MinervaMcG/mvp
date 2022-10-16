class TalentsIndex < Chewy::Index
  index_scope Talent
  field :verified, :activity_count, :created_at

  field :user do
    field :username, :display_name, :profile_type
    field :tags, value: ->(user, talent) { user.tags.map(&:description) }
  end

  field :talent_token do
    field :ticker, :contract_id, :deployed_at, :chain_id
  end
end
