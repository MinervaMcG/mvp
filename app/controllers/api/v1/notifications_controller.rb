class API::V1::NotificationsController < ApplicationController
  before_action :prevent_user_impersonation, only: [:mark_all_as_read, :mark_as_read]

  PER_PAGE = 10

  def index
    notifications = is_user_impersonated? ? [] : current_user.notifications.newest_first

    pagy, notifications = pagy(notifications, items: per_page)
    notifications = NotificationBlueprint.render_as_json(notifications, view: :normal)

    render(
      json: {
        notifications: notifications,
        pagination: {
          currentPage: pagy.page,
          lastPage: pagy.last
        }
      },
      status: :ok
    )
  end

  def mark_all_as_read
    current_user.notifications.where(read_at: nil).update_all(read_at: Time.current)

    render json: {success: "Notifications were marked as read"}, status: :ok
  end

  def mark_as_read
    notification = current_user.notifications.find(params[:notification_id])
    notification.mark_as_read! if notification.read_at.nil?

    render json: {success: "Notification successfully updated."},
      status: :ok
  end

  private

  def per_page
    params[:per_page] || PER_PAGE
  end
end
