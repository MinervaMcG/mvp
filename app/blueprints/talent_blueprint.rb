class TalentBlueprint < Blueprinter::Base
  fields :id, :profile_picture_url

  view :normal do
    fields :occupation, :headline, :user_id, :verified, :supporters_count, :total_supply, :market_cap, :market_cap_variance
    association :talent_token, blueprint: TalentTokenBlueprint, view: :normal
    association :user, blueprint: UserBlueprint, view: :normal

    field :is_following do |talent, options|
      options[:current_user_watchlist]&.include?(talent.user_id) || false
    end

    field :profile_picture_data do |talent, _options|
      talent.profile_picture_data ? JSON.parse(talent.profile_picture_data) : nil
    end

    field :max_supply do
      Talent.max_supply.to_s
    end

    field :supply_progress do |talent, _options|
      (talent.total_supply.to_f / Talent.max_supply) * 100
    end
  end

  view :extended do
    include_view :normal
    fields :banner_url, :profile, :public, :with_persona_id
    association :user, blueprint: UserBlueprint, view: :extended
    association :perks, blueprint: PerkBlueprint
    association :tags, blueprint: TagBlueprint do |talent, options|
      options[:tags] || talent.user.tags
    end
    field :connections_count do |talent, _options|
      talent.user.connections.count
    end
    field :followers_count do |talent, _options|
      talent.user.followers.count
    end
    field :following_count do |talent, _options|
      talent.user.following.count
    end
    field :supporting_count do |talent, _options|
      TalentSupporter.where(supporter_wallet_id: talent.user.wallet_id).count
    end
    field :banner_data do |talent, _options|
      talent.banner_data ? JSON.parse(talent.banner_data) : nil
    end
    association :milestones, blueprint: MilestoneBlueprint, view: :normal
    association :career_goal, blueprint: CareerGoalBlueprint, view: :normal
  end

  view :short_meta do
    fields :occupation, :supporters_count, :total_supply, :created_at
    association :talent_token, blueprint: TalentTokenBlueprint, view: :normal, name: :token
    field :username do |talent, options|
      talent.user.username
    end
  end
end
