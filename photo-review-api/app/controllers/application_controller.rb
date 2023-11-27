class ApplicationController < ActionController::API
  include ActionController::RequestForgeryProtection

  # protect_from_forgery with: :exception, unless: -> { request.format.json? }
  protect_from_forgery with: :null_session, unless: -> { request.format.json? }
  before_action :authenticate_user!
end
