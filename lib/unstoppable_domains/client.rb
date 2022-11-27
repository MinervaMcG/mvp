module UnstoppableDomains
  class Client
    BASE_URI = "https://resolve.unstoppabledomains.com"

    def get_address_domains(address:)
      url = "#{BASE_URI}/reverse/#{address}"

      Faraday.get(url, {}, headers)
    end

    private

    def headers
      {
        Authorization: "Bearer #{ENV["UNSTOPPABLE_DOMAINS_API_KEY"]}"
      }
    end
  end
end
