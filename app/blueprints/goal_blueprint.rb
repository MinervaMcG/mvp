class GoalBlueprint < Blueprinter::Base
  fields :id

  view :normal do
    fields :title, :due_date, :description, :link, :progress
    association :goal_images, blueprint: GoalImageBlueprint, view: :normal, name: :images
  end
end
