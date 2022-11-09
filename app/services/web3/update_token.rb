module Web3
  class UpdateToken
    class Error < StandardError; end

    class UpdateError < Error; end

    def initialize(token:, params:)
      @token = token
      @params = params
    end

    def call
      token.update!(update_params)

      token
    end

    private

    attr_reader :token, :params

    def update_params
      update_params = {
        show: params[:show],
        name: params[:name]
      }

      if token.erc_721?
        update_params[:description] = params[:description]
        update_params[:external_image_url] = params[:external_image_url]
      end

      update_params
    end
  end
end
