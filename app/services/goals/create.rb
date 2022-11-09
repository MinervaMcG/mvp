module Goals
  class Create
    def initialize(career_goal:, current_user:, params:)
      @career_goal = career_goal
      @current_user = current_user
      @params = params
    end

    def call
      goal = Goal.new(params.except(:images))

      parsed_date = params[:due_date].split("-").map(&:to_i)
      goal.due_date = Date.new(parsed_date[2], parsed_date[1], parsed_date[0])

      goal.career_goal = career_goal

      create_goal_images(goal: goal) if params[:images].length > 0

      goal.save!

      if career_goal.goals.length >= 1
        UpdateTasksJob.perform_later(type: "Tasks::Goals", user_id: current_user.id)
      end

      goal
    end

    private

    attr_reader :career_goal, :current_user, :params

    def create_goal_images(goal:)
      params[:images].each do |image|
        goal_image = goal.goal_images.build(image: image[:image_data].as_json)
        goal_image.image_derivatives!
      end
    end
  end
end
