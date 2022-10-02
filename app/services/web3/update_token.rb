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

      TokenImageUploaderJob.perform_later(token_id: token.id, token_class: token.class.name, image_url: params[:image_url]) if !token.erc_20? && params[:image_url]

      token
    end

    private

    attr_reader :token, :params

    def update_params
      update_params = {
        show: params[:show],
        name: params[:name]
      }

      update_params[:description] = params[:description] unless token.erc_20?

      update_params
    end
  end
end
