class CareerGoalBlueprint < Blueprinter::Base
  fields :id, :description

  view :normal do
    fields :target_date, :bio, :pitch, :challenges, :image
    field :goals do |career_goal, _options|
      career_goal.goals.order(:due_date)
    end
    association :career_needs, blueprint: CareerNeedBlueprint
  end
end
