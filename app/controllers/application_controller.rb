class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, unless: :from_slack

  def from_slack
    Certificate.slash_command_tokens.include?(request.params[:token])
  end

end
