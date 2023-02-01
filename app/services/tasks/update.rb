module Tasks
  class Update
    NOTIFICATION_MAP = {
      "Quests::VerifiedProfile" => Quests::VerifiedProfileNotification,
      "Quests::TalentProfile" => Quests::CompletedTalentProfileNotification
    }

    def call(type:, user:, normal_update: true)
      ActiveRecord::Base.transaction do
        task = Task.joins(:quest).where(type: type).where(quest: {user: user}).take
        task.with_lock do
          next if task.done?

          update_model(model: task, status: "done")
          update_model(model: task.quest, status: "doing")
          give_rewards_for_task(type: type, user: user) if normal_update
          next unless task.reload.quest.tasks.where.not(status: "done").count == 0

          update_model(model: task.quest, status: "done")
          give_rewards_for_quest(model: task.quest, user: user)
          create_notification(user: user, quest: task.quest) if normal_update
        end
      end
    end

    private

    def update_model(model:, status:)
      model.update!(status: status)
    end

    def give_rewards_for_task(type:, user:)
      if type == "Tasks::Watchlist"
        user.invites.where(talent_invite: false).update_all(max_uses: nil)
      elsif type == "Tasks::Verified"
        WhitelistUserJob.perform_later(user_id: user.id, level: "verified")
      elsif type == "Quests::VerifiedProfile"
        WhitelistUserJob.perform_later(user_id: user.id, level: "verified")
      elsif type == "Quests::TalentProfile"
        Reward.create!(user: user, amount: 50, category: "quest", reason: "completed profile")
      end
    end

    def give_rewards_for_quest(model:, user:)
      return unless model.done?

      if model.type == "Quests::TalentProfile"
        user.talent.update!(public: true)
      end
    end

    def create_notification(user:, quest:)
      CreateNotification.new.call(
        recipient: user,
        type: notification_from(quest.type),
        source_id: user.id,
        model_id: quest.id
      )
    end

    def notification_from(type)
      NOTIFICATION_MAP[type] || QuestCompletedNotification
    end
  end
end
