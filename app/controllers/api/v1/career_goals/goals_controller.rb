class API::V1::CareerGoals::GoalsController < ApplicationController
  before_action :validate_access

  def update
    service = Goals::Update.new(goal: goal, params: goal_params)
    updated_goal = service.call

    render json: GoalBlueprint.render(updated_goal, view: :normal), status: :ok
  rescue => e
    Rollbar.error(
      e,
      "Unable to update goal",
      goal_id: updated_goal.id,
      career_goal_id: career_goal.id
    )

    render json: {error: "Unable to update goal"}, status: :unprocessable_entity
  end

  def create
    service = Goals::Create.new(
      career_goal: career_goal,
      current_user: current_acting_user,
      params: goal_params
    )
    goal = service.call

    render json: GoalBlueprint.render(goal, view: :normal), status: :created
  rescue => e
    Rollbar.error(
      e,
      "Unable to create goal",
      goal_id: goal.id,
      career_goal_id: career_goal.id
    )

    render json: {error: "Unable to create goal"}, status: :unprocessable_entity
  end

  def destroy
    if goal.destroy
      render json: GoalBlueprint.render(goal, view: :normal), status: :ok
    else
      render json: {error: "Unable to delete requested goal."}, status: :unprocessable_entity
    end
  end

  private

  def career_goal
    @career_goal ||=
      CareerGoal.find(params[:career_goal_id])
  end

  def goal
    @goal ||= Goal.find(params[:id])
  end

  def goal_params
    params.require(:goal).permit(
      :title,
      :due_date,
      :description,
      :link,
      images: [
        :id,
        image_data: {}
      ]
    )
  end

  def validate_access
    if !current_user.admin? && career_goal.id != current_acting_user.talent.career_goal.id
      render json: {error: "You don't have access to perform that action"}, status: :unauthorized
    end
  end
end
