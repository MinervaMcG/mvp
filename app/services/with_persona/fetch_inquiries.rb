require "with_persona/client"

module WithPersona
  class FetchInquiries
    def call
      talents = Talent.where(verified: false).where.not(with_persona_id: nil).includes(:user)
      talents.each do |talent|
        request = client.fetch_inquiry(inquiry_id: talent.with_persona_id)
        inquiry = JSON.parse(request.body)

        inquiry_status = inquiry["data"]["attributes"]["status"]
        legal_first_name = inquiry["data"]["attributes"]["fields"]["name-first"]["value"]&.downcase || ""
        legal_last_name = inquiry["data"]["attributes"]["fields"]["name-last"]["value"]&.downcase || ""

        if inquiry_status == "completed"
          WithPersona::ApproveInquiry.new(
            talent: talent,
            inquiry_first_name: legal_first_name,
            inquiry_last_name: legal_last_name
          ).call
        end

        if inquiry_status == "failed" || inquiry_status == "expired"
          WithPersona::FailedInquiry.new(
            talent: talent
          ).call
        end
      end
    end

    private

    def client
      @client ||= ::WithPersona::Client.new
    end
  end
end
