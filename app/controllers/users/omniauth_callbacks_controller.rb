class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @user = User.find_for_facebook_oauth(request.env['omniauth.auth'])

    if @user.nil?
      flash[:alert] = I18n.t('profile_w_o_email', kind: 'Facebook')
      redirect_to root_path
    elsif @user.persisted?
      flash[:notice] = I18n.t('devise.omniauth_callbacks.success', kind: 'Facebook')
      sign_in_and_redirect @user, event: :authentication
    else
      flash[:alert] = I18n.t(
        'devise.omniauth_callbacks.failure',
        kind: 'Facebook',
        reason: 'authentication error'
      )

      redirect_to root_path
    end
  end

  def vkontakte
    @user = User.find_for_vkontakte_oauth(request.env["omniauth.auth"])

    if @user.nil?
      flash[:alert] = I18n.t('profile_w_o_email', kind: 'Vkontakte')
      redirect_to root_path
    elsif @user.persisted?
      flash[:notice] = I18n.t('devise.omniauth_callbacks.success', kind: 'Vkontakte')
       sign_in_and_redirect @user, event: :authentication
    else
      flash[:alert] = I18n.t(
        'devise.omniauth_callbacks.failure',
        kind: 'Vkontakte',
        reason: 'authentication error'
      )

      redirect_to root_path
    end
  end
end

