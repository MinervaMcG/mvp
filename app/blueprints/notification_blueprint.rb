class NotificationBlueprint < Blueprinter::Base
  fields :id

  view :normal do
    fields :type, :created_at

    field :read do |record, _options|
      record.read?
    end

    field :body do |record, _options|
      notification_from(record).body
    end

    field :title do |record, _options|
      notification_from(record).title
    end

    field :url do |record, _options|
      notification_from(record).url
    end
  end

  # Cache the .to_notification transformation
  def self.notification_from(record)
    notifications[record.id] ||= record.to_notification
  end

  def self.notifications
    @notifications ||= {}
  end
end
