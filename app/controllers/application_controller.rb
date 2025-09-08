class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  def authenticate_user_from_token
    authenticate_with_http_token do |token, options|
      @current_user = User.find_by(authentication_token: token)
    end
  end

  def current_user
    @current_user || super
  end

  def user_signed_in?
    current_user.present?
  end
end
