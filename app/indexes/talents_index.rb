class TalentsIndex < Chewy::Index
  index_scope Talent
  field :verified, :activity_count, :created_at, :updated_at

  field :user do
    field :username, :display_name, :profile_type, :legal_first_name, :legal_last_name
    field :tags, value: ->(user, talent) { user.tags.map(&:description) }
  end

  field :talent_token do
    field :ticker, :contract_id, :deployed_at, :chain_id
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
