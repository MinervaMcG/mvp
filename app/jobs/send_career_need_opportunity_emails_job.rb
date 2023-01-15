class SendCareerNeedOpportunityEmailsJob < ApplicationJob
  queue_as :default

  def perform
    send_opportunities_open_roles_emails
    send_opportunities_role_landed_emails
    send_opportunities_hiring_emails
    send_opportunities_talent_found_emails
  end

  private

  def send_opportunities_open_roles_emails
    User
      .joins(talent: {career_goal: :career_needs})
      .left_outer_joins(:user_email_log)
      .where(career_needs: {title: CareerNeed::ROLE_NEEDS})
      .where("sent_at_data ->> 'opportunities_open_roles' IS ? OR sent_at_data ->> 'opportunities_open_roles' < ?", nil, three_months_ago)
      .distinct
      .find_each do |user|
        UserMailer.with(user: user).send_opportunities_open_roles_email.deliver_later
        persist_sent_at(email: "opportunities_open_roles", user: user)
      end
  end

  def send_opportunities_role_landed_emails
    User
      .joins(:user_email_log)
      .where("sent_at_data ->> 'opportunities_open_roles' IS NOT ?", nil)
      .where("sent_at_data ->> 'opportunities_role_landed' IS ? OR sent_at_data ->> 'opportunities_role_landed' < ?", nil, three_months_ago)
      .where("users.id NOT IN (?)", Talent.select(:user_id).joins(career_goal: :career_needs).where(career_needs: {title: CareerNeed::ROLE_NEEDS}))
      .find_each do |user|
        UserMailer.with(user: user).send_opportunities_role_landed_email.deliver_later
        persist_sent_at(email: "opportunities_role_landed", user: user)
      end
  end

  def send_opportunities_hiring_emails
    User
      .joins(talent: {career_goal: :career_needs})
      .left_outer_joins(:user_email_log)
      .where(career_needs: {title: CareerNeed::HIRING_NEEDS})
      .where("sent_at_data ->> 'opportunities_hiring' IS ? OR sent_at_data ->> 'opportunities_hiring' < ?", nil, three_months_ago)
      .distinct
      .find_each do |user|
        UserMailer.with(user: user).send_opportunities_hiring_email.deliver_later
        persist_sent_at(email: "opportunities_hiring", user: user)
      end
  end

  def send_opportunities_talent_found_emails
    User
      .joins(:user_email_log)
      .where("sent_at_data ->> 'opportunities_hiring' IS NOT ?", nil)
      .where("sent_at_data ->> 'opportunities_talent_found' IS ? OR sent_at_data ->> 'opportunities_talent_found' < ?", nil, three_months_ago)
      .where("users.id NOT IN (?)", Talent.select(:user_id).joins(career_goal: :career_needs).where(career_needs: {title: CareerNeed::HIRING_NEEDS}))
      .find_each do |user|
        UserMailer.with(user: user).send_opportunities_talent_found_email.deliver_later
        persist_sent_at(email: "opportunities_talent_found", user: user)
      end
  end

  def three_months_ago
    Time.current - 3.months
  end

  def persist_sent_at(email:, user:)
    user_email_log = user.user_email_log || user.build_user_email_log
    user_email_log.sent_at_data[email] = Time.current
    user_email_log.save!
  end
end
