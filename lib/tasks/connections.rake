namespace :connections do
  task setup: :environment do
    count = TalentSupporter.count

    TalentSupporter.find_each.with_index do |tp, index|
      puts "TP #{index}/#{count}"
      user = User.find_by(wallet_id: tp.supporter_wallet_id)
      connected_user = User.joins(talent: :talent_token).find_by(talent_tokens: {contract_id: tp.talent_contract_id})

      next if user.nil? || connected_user.nil?

      supporting_connection ||= Connection.find_or_initialize_by(
        user: user,
        connected_user: connected_user
      )

      supporting_connection.refresh_connection!

      supporter_connection ||= Connection.find_or_initialize_by(
        user: connected_user,
        connected_user: user
      )

      supporter_connection.refresh_connection!
    end

    count = Follow.count
    Follow.find_each.with_index do |follow, index|
      puts "TP #{index}/#{count}"
      following_connection ||= Connection.find_or_initialize_by(
        user: follow.user,
        connected_user: follow.follower
      )

      following_connection.refresh_connection!

      follower_connection ||= Connection.find_or_initialize_by(
        user: follow.follower,
        connected_user: follow.user
      )

      follower_connection.refresh_connection!
    end
  end
end
