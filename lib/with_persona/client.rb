module WithPersona
  class Client
    INQUIRY_URI = "https://withpersona.com/api/v1/inquiries"

    def fetch_inquiry(inquiry_id:)
      Faraday.get(
        "#{INQUIRY_URI}/#{inquiry_id}",
        {},
        {
          Authorization: "Bearer #{ENV["WITH_PERSONA_API_KEY"]}",
          "Content-Type": "application/vnd.api+json"
        }
      )
    end
  end
end
