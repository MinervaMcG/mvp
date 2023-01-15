class PersonaWebhookReceivedJob < ApplicationJob
  queue_as :default

  def perform(params:)
    event_type = event_type(params)

    case event_type
    when "verification.created"
      increase_requests_counter
    when "inquiry.approved"
      approve_inquiry(params)
    when "inquiry.decline", "inquiry.failed", "inquiry.expired"
      decline_inquiry(params)
    end
  end

  private

  def event_type(params)
    params["attributes"]["name"]
  end

  def increase_requests_counter
    current_month_persona_request = WithPersonaRequest.current_month_persona_request
    requests_counter = current_month_persona_request.requests_counter
    current_month_persona_request.update!(requests_counter: requests_counter + 1)
  end

  def approve_inquiry(params)
    talent = Talent.find_by!(with_persona_id: inquiry_id_from(params))
    legal_first_name = inquiry_data_from(params)["attributes"]["fields"]["name-first"]["value"]&.downcase || ""
    legal_last_name = inquiry_data_from(params)["attributes"]["fields"]["name-last"]["value"]&.downcase || ""

    WithPersona::ApproveInquiry.new(
      talent: talent,
      inquiry_first_name: legal_first_name,
      inquiry_last_name: legal_last_name
    ).call
  end

  def decline_inquiry(params)
    talent = Talent.find_by!(with_persona_id: inquiry_id_from(params))

    WithPersona::FailedInquiry.new(
      talent: talent
    ).call
  end

  def inquiry_id_from(params)
    inquiry_data_from(params)["id"]
  end

  def inquiry_data_from(params)
    params["attributes"]["payload"]["data"]
  end
end
