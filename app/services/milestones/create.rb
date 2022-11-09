module Milestones
  class Create
    def initialize(talent:, current_user:, params:)
      @talent = talent
      @current_user = current_user
      @params = params
    end

    def call
      milestone = Milestone.new(params.except(:images))

      parsed_date = params[:start_date].split("-").map(&:to_i)
      milestone.start_date = Date.new(parsed_date[2], parsed_date[1], parsed_date[0])
      if params[:end_date].length > 0
        parsed_date = params[:end_date].split("-").map(&:to_i)
        milestone.end_date = Date.new(parsed_date[2], parsed_date[1], parsed_date[0])
      end

      create_milestone_images(milestone: milestone) if params[:images].length > 0
      milestone.talent = talent

      milestone.save!

      if talent.milestones.length >= 1
        UpdateTasksJob.perform_later(type: "Tasks::Highlights", user_id: current_user.id)
      end

      milestone
    end

    private

    attr_reader :talent, :current_user, :params

    def create_milestone_images(milestone:)
      params[:images].each do |image|
        milestone_image = milestone.milestone_images.build(image: image[:image_data].as_json)
        milestone_image.image_derivatives!
      end
    end
  end
end
