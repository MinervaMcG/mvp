class GoalImageBlueprint < Blueprinter::Base
  fields :id

  view :normal do
    fields :image_url
  end
end
