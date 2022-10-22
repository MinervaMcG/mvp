class PartnershipBlueprint < Blueprinter::Base
  fields :id

  view :normal do
    fields :banner_url, :button_name, :button_url, :location, :logo_url, :twitter_url, :website_url
  end
end
