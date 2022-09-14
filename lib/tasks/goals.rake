namespace :goals do
  desc "Set due date to end of the month"
  task set_due_date_to_end_of_month: :environment do
    Goal.find_each do |goal|
      goal.update!(due_date: goal.due_date.end_of_month)
    end
  end
end
