class ProfileBlueprint < Blueprinter::Base
  fields :id, :profile_picture_url

  view :normal do
    fields :occupation, :headline, :user_id, :verified, :supporters_count, :total_supply
    association :talent_token, blueprint: TalentTokenBlueprint, view: :normal
    association :user, blueprint: UserBlueprint, view: :normal

    field :tags do |talent, _options|
      talent.user.tags.map { |tag| tag["description"] }
    end

    field :is_following do |talent, options|
      options[:current_user_watchlist]&.include?(talent.user_id) || false
    end
  end
end
