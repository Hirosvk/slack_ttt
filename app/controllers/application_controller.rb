class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, unless: :from_slack

  def from_slack
    SLACK_TOKENS.include?(request.params[:token])
  end

  SLACK_TOKENS = [
    "gIkuvaNzQIHg97ATvDxqgjtO", # -for testing
    "JMN4zMcOJJnJTpBiu4NNdtIr", # /show_board
    "CmViLMXuqm56gq8rTDll6SvR", # /challenge
    "pGaNxx5S7OpLruQ9a0cs9j84", # /accept
    "o92ITKog4nn3k7TATv1ZsNAt", # /decline
    "6svC7Ug5JWRyyvTknUQsI9f2", # /mark
    "X37bTyhXOyoQ4QaXPE5eZh41", # /abandon
    "yJgkg2ct70GaiZlAaEoLDSoc", # /how
    "hBvuKo5qVKpRk4H1qIn76UZ3"  # app token
  ]


end
