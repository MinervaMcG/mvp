# frozen_string_literal: true

namespace :collective do
  task create_takeoff_lisbon: :environment do
    puts "Setting up Take Off Lisbon Collective"
    logo = "https://i.ibb.co/5snntsk/Symbol-White-Default.png"
    banner = "https://i.ibb.co/PQCWgsP/1500x500-4.jpg"
    tags = ["Community", "Scholarship", "Web3"]
    slug = "takeoff-lisbon"

    org = Organization.find_or_initialize_by(slug: slug)
    org.name = "Take Off Lisbon"
    org.slug = slug
    org.website = "https://takeoff.talentprotocol.com/"
    org.description = "Vote on your favorite candidate to win a scholarship for ETHLisbon. Every vote has a cost in $TAL, but if you predict the winner(s), you'll win a prize."
    org.verified = true
    org.type = "Organizations::Election"
    org.location = "Lisbon, Portugal"
    if org.new_record?
      tags.each do |tag|
        org.tags << Tag.find_or_create_by(description: tag)
      end

      org.logo_attacher.context[:url] = true
      org.logo = Down.open(logo)

      org.banner_attacher.context[:url] = true
      org.banner = Down.open(banner)
    end

    org.save!
    puts "Successfully created organization - #{org.name}"

    # Create election
    puts "Creating election for Takeoff Lisbon"
    election = Election.find_or_initialize_by(organization_id: org.id)
    election.start_date = Date.parse("2023-09-29")
    election.voting_start_date = Date.parse("2023-09-29")
    election.voting_end_date = Date.parse("2023-10-06")
    election.terms_and_conditions_url = "https://talentprotocol.notion.site/ETHLisbon-Scholarship-Terms-Conditions-53728b65acfa41f7abb9becfe544c2b4"
    election.learn_more_url = "https://blog.talentprotocol.com/eth-lisbon-scholarship/"
    election.save!
    puts "Successfully created election for #{org.name}"
  end
end
