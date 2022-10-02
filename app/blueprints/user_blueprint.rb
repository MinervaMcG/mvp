class UserBlueprint < Blueprinter::Base
  fields :id

  view :normal do
    fields :username, :display_name, :profile_type, :created_at
    field :name do |user, _options|
      user.name
    end
    field :is_talent do |user, _options|
      user.talent.present?
    end
    field :investor_id do |user, _options|
      user.investor&.id
    end
  end

  view :extended do
    include_view :normal
    fields :email, :wallet_id, :profile_type, :admin?

    field :invited_by do |user, _options|
      if user.invited
        {
          name: user.invited.user.name,
          profile_picture_url: user.invited.user.profile_picture_url
        }
      end
    end
  end

  view :with_pictures do
    include_view :normal
    field :profilePictureUrl do |user, _options|
      user.profile_picture_url
    end
  end

  view :rewards do
    include_view :with_pictures

    fields :created_at

    field :ticker do |user, _options|
      user.talent&.talent_token&.ticker
    end

    field :status do |user, _options|
      if user&.talent&.talent_token&.deployed?
        "Token Launched"
      elsif user.beginner_quest_completed?
        "Profile Complete"
      else
        "Registered"
      end
    end
  end
end
