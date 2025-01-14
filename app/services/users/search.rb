module Users
  class Search
    def initialize(search_params:)
      @search_params = search_params
    end

    def call
      users = User.all

      users = filter_by_collective(users) if filter_by_collective?
      users = filter_by_name(users) if filter_by_name?
      users = filter_by_ids(users) if filter_by_ids?
      users = filter_by_messaging_disabled(users) if filter_by_messaging_disabled?

      users
    end

    private

    attr_reader :search_params

    def filter_by_ids(users)
      users.where("wallet_id IN (:ids) OR username IN (:ids)", ids: search_params[:ids])
    end

    def filter_by_name(users)
      users.where("username ilike :name OR display_name ilike :name", name: "%#{search_params[:name]}%")
    end

    def filter_by_collective(users)
      users.joins(:organizations).where(organizations: {slug: search_params[:collective_slug]})
    end

    def filter_by_name?
      search_params[:name].present?
    end

    def filter_by_collective?
      search_params[:collective_slug].present?
    end

    def filter_by_ids?
      search_params[:ids].present? && search_params[:ids].reject(&:blank?).map(&:downcase).any?
    end

    def filter_by_messaging_disabled(users)
      users.where(messaging_disabled: search_params[:messaging_disabled])
    end

    def filter_by_messaging_disabled?
      search_params.key?(:messaging_disabled)
    end
  end
end
