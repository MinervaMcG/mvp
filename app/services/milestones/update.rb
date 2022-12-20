module Milestones
  class Update
    class Error < StandardError; end

    class StartDateAfterEndDateError < Error; end

    def initialize(milestone:, current_user:, params:)
      @milestone = milestone
      @current_user = current_user
      @params = params
    end

    def call
      milestone.assign_attributes(params.except(:images))
      parsed_date = params[:start_date].split("-").map(&:to_i)
      milestone.start_date = Date.new(parsed_date[2], parsed_date[1], parsed_date[0])
      if params[:end_date].length > 0
        parsed_date = params[:end_date].split("-").map(&:to_i)
        milestone.end_date = Date.new(parsed_date[2], parsed_date[1], parsed_date[0])
      end

      validate_milestone_dates!(milestone)

      update_milestone_images

      milestone.save!

      milestone
    end

    private

    attr_reader :milestone, :current_user, :params

    def validate_milestone_dates!(milestone)
      return unless milestone.end_date

      raise StartDateAfterEndDateError, "Start date needs to be before the end date" if milestone.start_date > milestone.end_date
    end

    def update_milestone_images
      existing_ids = params[:images].map { |img| img[:id] }.compact
      MilestoneImage.where(milestone: milestone).where.not(id: existing_ids).destroy_all
      if params[:images].count > 0
        params[:images].filter { |img| !img[:id] }.each do |image|
          next unless image.key?(:image_data)

          milestone_image = milestone.milestone_images.create!(image: image[:image_data].as_json)
          milestone_image.image_derivatives!
        end
      end
    end
  end
end
