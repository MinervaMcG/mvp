class TalentsIndex < Chewy::Index
  index_scope Talent
  field :verified, type: "boolean"
  field :activity_count
  field :created_at, type: "date"

  field :user do
    field :username, :display_name, :profile_type, :legal_first_name, :legal_last_name
    field :tags, value: ->(user, talent) { user.tags.map(&:description) }
  end

  field :talent_token do
    field :ticker, :contract_id, :chain_id
    field :deployed_at, type: "date"
  end

  field :occupation, value: ->(talent) { talent.profile[:occupation] }

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
