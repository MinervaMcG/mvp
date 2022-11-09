module Goals
  class Update
    def initialize(goal:, params:)
      @goal = goal
      @params = params
    end

    def call
      goal.assign_attributes(params.except(:images))
      parsed_date = params[:due_date].split("-").map(&:to_i)
      goal.due_date = Date.new(parsed_date[2], parsed_date[1], parsed_date[0])

      update_goal_images

      goal.save!

      goal
    end

    private

    attr_reader :goal, :params

    def update_goal_images
      existing_ids = params[:images].map { |img| img[:id] }.compact
      GoalImage.where(goal: goal).where.not(id: existing_ids).destroy_all

      if params[:images].count > 0
        params[:images].filter { |img| !img[:id] }.each do |image|
          next unless image.key?(:image_data)

          goal_image = goal.goal_images.create!(image: image[:image_data].as_json)
          goal_image.image_derivatives!
        end
      end
    end
  end
end
