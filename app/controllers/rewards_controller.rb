class RewardsController < ApplicationController
  PER_PAGE = 10

  def index
    @invites = current_acting_user.invites.common

    @races_count = Race.count
    @user_rewards = current_acting_user.rewards
    @current_race = Race.active_race || Race.where("started_at >= ?", Date.new(2022, 8, 15)).order(started_at: :asc).first
    # Only show races after the second batch of races
    @races = Race.where("started_at >= ? AND ends_at < ?", Date.new(2022, 8, 15), Date.current).or(Race.where(id: @current_race&.id))

    race_registered_users = User.where.not(race_id: nil)
    @race_registered_users_count = race_registered_users.count
    @users_that_invited_others_count =
      race_registered_users
        .includes(:invites)
        .where(invites: {talent_invite: false})
        .where("users.username = invites.code")
        .count
    race_rewards = Reward.race.order(amount: :desc).includes([user: :talent])
    @race_rewards = RewardBlueprint.render_as_json(race_rewards, view: :normal)

    @pagy, invited_users = pagy(User.where(invited: @invites), items: per_page)
    @invited_users =
      UserBlueprint.render_as_json(
        invited_users.includes([talent: :talent_token]).order(created_at: :desc),
        view: :rewards
      )

    service = Races::PrepareRaceResults.new(race: @current_race, user: current_acting_user)
    @race_leaderboard_results = service.call

    @race_invites_count = if @current_race
      User.joins(:invites)
        .where(invite_id: current_acting_user.invites.pluck(:id))
        .where("users.username = invites.code and users.created_at >= ?", @current_race.started_at)
        .count
    else
      0
    end

    quests = Quest.where(user: current_acting_user).order(:id)
    @quests = QuestBlueprint.render_as_json(quests.includes(:user, :tasks), view: :normal)

    respond_to do |format|
      format.html
      format.json {
        render(
          json: {
            invitedUsers: @invited_users,
            pagination: {
              currentPage: @pagy.page,
              lastPage: @pagy.last
            }
          },
          status: :ok
        )
      }
    end
  end

  private

  def per_page
    params[:per_page] || PER_PAGE
  end
end
