class Notifications < ActionMailer::Base
  include ActionController::RecordIdentifier
  include Admin::DocumentRoutesHelper

  def fact_check_request(request, url_options)
    @fact_check_request = request
    @url_options = url_options

    from_address = no_reply_email_address(url_options)
    to_address = request.email_address
    subject = "Fact checking request from #{request.requestor.name}: #{request.document.title}"

    mail(from: from_address, to: to_address, subject: subject)
  end

  def fact_check_response(request, url_options)
    @fact_check_request = request
    @url_options = url_options
    @comment_url = admin_document_url(request.document, url_options.merge(anchor: dom_id(request)))

    from_address = no_reply_email_address(url_options)
    to_address = request.requestor.email
    subject = "Fact check comment added by #{request.email_address}: #{request.document.title}"

    mail(from: from_address, to: to_address, subject: subject)
  end

  private

  def no_reply_email_address(url_options)
    "DO NOT REPLY <no-reply@#{url_options[:host]}>"
  end
end
