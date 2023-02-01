class TalentsIndex < Chewy::Index
  index_scope Talent
    .joins(:user)
    .includes(
      :talent_token,
      :milestones,
      career_goal: [:goals, :career_needs],
      user: [{tags: :discovery_row}, :quests]
    )
  field :market_cap, :user_id, :supporters_count, :activity_count
  field :verified, type: "boolean"
  field :public, type: "boolean"
  field :hide_profile, type: "boolean"
  field :created_at, type: "date"
  field :id, type: "integer"
  field :profile_complete, value: ->(talent) do
    talent.user.quests.where(type: "Quests::TalentProfile", status: "done").exists?
  end
  field :supply_progress, value: ->(talent) do
    (talent.total_supply.to_f / Talent.max_supply) * 100
  end

  field :user do
    field :id, :username, :display_name, :profile_type, :legal_first_name, :legal_last_name
    field :tags, value: ->(user, talent) { user.tags.map(&:description) }
    field :name, value: ->(user, talent) { user.name }
    field :discovery_row_ids, value: ->(user, talent) do
      user.tags.pluck(:discovery_row_id)
    end
  end

  field :talent_token do
    field :ticker, :contract_id, :chain_id
    field :deployed_at, type: "date"
  end

  field :occupation, value: ->(talent) { talent.profile[:occupation] }
  field :headline, value: ->(talent) { talent.profile[:headline] }
  field :location, value: ->(talent) { talent.profile[:location] }

  field :milestones do
    field :institution, :title, :description
  end

  field :career_goal do
    field :description, :pitch
    field :goals do
      field :description, :title
    end
    field :career_needs do
      field :title
    end
  end
end
