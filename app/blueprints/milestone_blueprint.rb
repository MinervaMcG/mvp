class MilestoneBlueprint < Blueprinter::Base
  fields :id, :title, :description

  view :normal do
    fields :start_date, :end_date, :link, :institution, :category, :in_progress
    association :milestone_images, blueprint: MilestoneImageBlueprint, view: :normal, name: :images
  end
end
