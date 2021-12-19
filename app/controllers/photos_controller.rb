class PhotosController < ApplicationController
  before_action :set_event, only: [:create, :destroy]
  before_action :set_photo, only: [:destroy]

  def create
    @new_photo = @event.photos.build(photo_params)
    @new_photo.user = current_user

    if attempt_to_access_to_private_event?(@event)
      flash[:alert] = I18n.t('pundit.not_authorized')
      return redirect_to @event
    end

    if @new_photo.save
      notify_subscribers(@event, @new_photo)
      flash[:notice] = I18n.t('controllers.photos.created')
      redirect_to @event
    else
      flash.now[:alert] = I18n.t('controllers.photos.error')
      render 'events/show'
    end
  end

  def destroy
    type, message = :notice, I18n.t('controllers.photos.destroyed')

    if current_user_can_edit?(@photo)
      @photo.destroy
    else
      type, message = :alert, I18n.t('controllers.photos.error')
    end

    flash[type] = message
    redirect_to @event
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_photo
    @photo = @event.photos.find(params[:id])
  end

  def photo_params
    params.fetch(:photo, {}).permit(:photo)
  end

  def notify_subscribers(event, photo)
    all_emails = (event.subscriptions.map(&:user_email) + [event.user.email] - [photo.user.email]).uniq

    all_emails.each do |mail|
      EventMailer.photo(event, photo, mail).deliver_now
    end
  end
end
