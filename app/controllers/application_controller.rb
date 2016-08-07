class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, unless: :from_slack
  
  def from_slack
    request.params[:token] == "gIkuvaNzQIHg97ATvDxqgjtO"
  end
end
