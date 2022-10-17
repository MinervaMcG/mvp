namespace :milestones do
  task add_base_category: :environment do
    Milestone.update_all(category: "Position")
  end
end
