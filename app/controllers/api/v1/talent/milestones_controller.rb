class API::V1::Talent::MilestonesController < ApplicationController
  before_action :validate_access
  after_action :notify_of_change

  def update
    service = Milestones::Update.new(
      milestone: milestone,
      current_user: current_acting_user,
      params: milestone_params
    )
    updated_milestone = service.call

    render json: MilestoneBlueprint.render(updated_milestone, view: :normal), status: :ok
  rescue => e
    Rollbar.error(
      e,
      "Unable to update milestone",
      milestone_id: updated_milestone.id,
      talent_id: talent.id
    )

    render json: {error: "Unable to update milestone"}, status: :unprocessable_entity
  end

  def create
    service = Milestones::Create.new(
      talent: talent,
      current_user: current_acting_user,
      params: milestone_params
    )
    milestone = service.call

    render json: MilestoneBlueprint.render(milestone, view: :normal), status: :created
  rescue => e
    Rollbar.error(
      e,
      "Unable to create milestone",
      milestone_id: milestone.id,
      talent_id: talent.id
    )

    render json: {error: "Unable to create milestone"}, status: :unprocessable_entity
  end

  def destroy
    if milestone.destroy
      render json: MilestoneBlueprint.render(milestone, view: :normal), status: :ok
    else
      render json: {error: "Unable to delete requested milestone."}, status: :unprocessable_entity
    end
  end

  private

  def notify_of_change
    CreateNotificationTalentChangedJob.perform_later(talent.user.followers.pluck(:follower_id), talent.user_id)
  end

  def talent
    @talent ||=
      if talent_id_param
        Talent.find(params[:talent_id])
      else
        Talent.find_by!(public_key: params[:talent_id])
      end
  end

  def milestone
    @milestone ||= Milestone.find(params[:id])
  end

  def milestone_params
    params.require(:milestone).permit(
      :title,
      :start_date,
      :end_date,
      :institution,
      :description,
      :link,
      :category,
      :in_progress,
      images: [
        :id,
        image_data: {}
      ]
    )
  end

  def validate_access
    if !current_user.admin? && talent.id != current_acting_user.talent&.id
      render json: {error: "You don't have access to perform that action"}, status: :unauthorized
    end
  end
end
