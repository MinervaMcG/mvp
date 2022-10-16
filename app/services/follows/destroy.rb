module Follows
  class Destroy
    class Error < StandardError; end

    class DestroyError < Error; end

    def initialize(follow:)
      @follow = follow
      @follower_user = follow.follower
      @following_user = follow.user
    end

    def call
      raise DestroyError.new(follow.error.full_messages) unless follow.destroy

      update_follower_connection
      update_following_connection
    end

    private

    attr_reader :follow, :follower_user, :following_user

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
