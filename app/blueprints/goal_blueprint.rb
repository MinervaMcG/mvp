class GoalBlueprint < Blueprinter::Base
  fields :id

  view :normal do
    fields :title, :due_date, :description, :link
  end
end
