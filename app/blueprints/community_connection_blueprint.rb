class CommunityConnectionBlueprint < Blueprinter::Base
  fields :id

  view :normal do
    fields :user_invested_amount, :connected_user_invested_amount, :connection_type, :connected_at

    field :username do |connection, _options|
      connection.connected_user.username
    end

    field :name do |connection, _options|
      connection.connected_user.name
    end

    field :profile_picture_url do |connection, _options|
      connection.connected_user.profile_picture_url
    end

    field :ticker do |connection, _options|
      connection.connected_user&.talent&.talent_token&.ticker
    end
  end
end
