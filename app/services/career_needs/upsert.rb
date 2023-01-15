module CareerNeeds
  class Upsert
    class Error < StandardError; end

    def initialize(career_goal:, titles:)
      @career_goal = career_goal
      @titles = titles
    end

    def call
      CareerNeed.transaction do
        destroy_career_needs
        upsert_career_needs
      end
    end

    private

    attr_reader :career_goal, :titles

    def destroy_career_needs
      career_goal.career_needs.where.not(title: titles).delete_all
    end

    def upsert_career_needs
      titles.each do |title|
        CareerNeed.find_or_create_by!(career_goal: career_goal, title: title)
      end
    end
  end
end
