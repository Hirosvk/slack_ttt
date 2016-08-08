class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, unless: :from_slack

  def from_slack
    SLACK_TOKENS.include?(request.params[:token])
  end

  SLACK_TOKENS = [
    "gIkuvaNzQIHg97ATvDxqgjtO", # for testing
    "JMN4zMcOJJnJTpBiu4NNdtIr", # /show_board
    "CmViLMXuqm56gq8rTDll6SvR"  # /challenge
  ]
end
