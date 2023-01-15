class UserBlueprint < Blueprinter::Base
  fields :id

  view :normal do
    fields :username, :display_name, :profile_type, :created_at, :legal_first_name, :legal_last_name

    field :talent_id do |user, _options|
      user.talent.id
    end

    field :name do |user, _options|
      user.name
    end

    field :is_talent do |user, _options|
      user.talent.present?
    end

    field :visible_digital_collectibles do |user, _options|
      user.visible_digital_collectibles?
    end
  end

  view :extended do
    include_view :normal
    fields :email, :wallet_id, :profile_type, :admin?

    field :approved_by do |user, _options|
      if user.approved_by
        {
          name: user.approved_by.name,
          profile_picture_url: user.approved_by.profile_picture_url
        }
      end
    end

    field :invited_by do |user, _options|
      if user.invited
        {
          name: user.invited.name,
          profile_picture_url: user.invited.profile_picture_url
        }
      end
    end

    field :profile_completed do |user, _options|
      user.profile_completed?
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
