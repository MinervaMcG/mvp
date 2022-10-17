module Follows
  class Create
    class Error < StandardError; end

    class AlreadyExistsError < Error; end

    class CreationError < Error; end

    def initialize(follower_user:, following_user:)
      @follower_user = follower_user
      @following_user = following_user
    end

    def call
      follow = Follow.find_or_initialize_by(user: following_user, follower: follower_user)

      raise AlreadyExistsError.new if follow.persisted?

      raise CreationError.new(follow.error.full_messages) unless follow.save

      update_tasks if more_than_2_follows?

      update_follower_connection
      update_following_connection

      follow
    end

    private

    attr_reader :follower_user, :following_user

    def more_than_2_follows?
      Follow.where(follower: follower_user).count > 2
    end

    def update_tasks
      UpdateTasksJob.perform_later(type: "Tasks::Watchlist", user_id: follower_user.id)
    end

    def update_follower_connection
      connection ||= Connection.find_or_initialize_by(
        user: follower_user,
        connected_user: following_user
      )

      connection.refresh_connection!
    end

    def update_following_connection
      connection ||= Connection.find_or_initialize_by(
        user: following_user,
        connected_user: follower_user
      )

      connection.refresh_connection!
    end
  end
end
