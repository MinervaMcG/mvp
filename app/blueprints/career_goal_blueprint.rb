class CareerGoalBlueprint < Blueprinter::Base
  fields :id, :description

  view :normal do
    fields :target_date, :bio, :pitch, :challenges, :image_url
    field :image_data do |talent, _options|
      talent.image_data ? JSON.parse(talent.image_data) : nil
    end
    association :goals, blueprint: GoalBlueprint, view: :normal
    association :career_needs, blueprint: CareerNeedBlueprint
  end
end
