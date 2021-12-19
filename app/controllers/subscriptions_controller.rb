class SubscriptionsController < ApplicationController
  before_action :set_event, only: [:create, :destroy]
  before_action :set_subscription, only: [:destroy]

  def create
    @new_subscription = @event.subscriptions.build(subscription_params)
    @new_subscription.user = current_user

    if attempt_to_access_to_private_event?(@event)
      flash[:alert] = I18n.t('pundit.not_authorized')
      return redirect_to @event
    end

    if current_user == @event.user
      flash.now[:alert] = I18n.t('controllers.subscriptions.owner_subscribed_error')
      render 'events/show'
    elsif @new_subscription.save
      EventMailer.subscription(@event, @new_subscription).deliver_now
      flash[:notice] = I18n.t('controllers.subscriptions.created')
      redirect_to @event
    else
      flash.now[:alert] = I18n.t('controllers.subscriptions.error')
      render 'events/show'
    end
  end

  def destroy
    type, message = :notice, I18n.t('controllers.subscriptions.destroyed')

    if current_user_can_edit?(@subscription)
      @subscription.destroy
    else
      type, message = :alert, I18n.t('controllers.subscriptions.error')
    end

    flash[type] = message
    redirect_to @event
  end

  private

  def set_subscription
    @subscription = @event.subscriptions.find(params[:id])
  end

  def set_event
    @event = Event.find(params[:event_id])
  end

  def subscription_params
    params.fetch(:subscription, {}).permit(:user_email, :user_name)
  end
end
