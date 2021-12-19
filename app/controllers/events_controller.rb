class EventsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  before_action :set_event, only: [:show, :destroy, :edit, :update]
  after_action :verify_authorized, only: [:show, :destroy, :edit, :update]
  after_action :verify_policy_scoped, only: :index

  def index
    @events = policy_scope(Event)
  end

  def show
    if params[:pincode].present? && @event.pincode_valid?(params[:pincode])
      cookies.permanent["events_#{@event.id}_pincode"] = params[:pincode]
    end

    authorize @event

    @new_comment = @event.comments.build(params[:comment])
    @new_subscription = @event.subscriptions.build(params[:subscription])
    @new_photo = @event.photos.build(params[:photo])
  end

  def new
    @event = current_user.events.build
  end

  def edit
    authorize @event
  end

  def create
    @event = current_user.events.build(event_params)

    if @event.save
      flash[:notice] = I18n.t('controllers.events.created')
      redirect_to @event
    else
      render :new
    end
  end

  def update
    authorize @event

    if @event.update(event_params)
      flash[:notice] = I18n.t('controllers.events.updated')
      redirect_to @event
    else
      render :edit
    end
  end

  def destroy
    authorize @event

    @event.destroy
    flash[:notice] = I18n.t('controllers.events.destroyed')
    redirect_to events_url
  end

  protected

  def user_not_authorized
    unless policy(@event).show?
      flash.now[:alert] = I18n.t('controllers.events.wrong_pincode') if params[:pincode].present?
      render :password_form
    else
      super
    end
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :address, :datetime, :description, :pincode)
  end
end
