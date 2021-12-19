class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  helper_method :current_user_can_edit?
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def current_user_can_edit?(model)
    user_signed_in? && (
      model.user == current_user ||
      (model.try(:event).present? && model.event.user == current_user)
    )
  end

  def attempt_to_access_to_private_event?(event)
    event.pincode.present? && !event.pincode_valid?(cookies.permanent["events_#{event.id}_pincode"]) && current_user != event.user
  end

  def pundit_user
    UserContext.new(current_user, cookies)
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:email, :password,
                                                              :password_confirmation,
                                                              :current_password])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  def user_not_authorized
    flash[:alert] = t('pundit.not_authorized')
    redirect_to(request.referrer || root_path)
  end
end
