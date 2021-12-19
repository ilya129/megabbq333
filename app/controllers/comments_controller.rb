class CommentsController < ApplicationController
  before_action :set_event, only: [:create, :destroy]
  before_action :set_comment, only: [:destroy]

  def create
    @new_comment = @event.comments.build(comment_params)
    @new_comment.user = current_user

    if attempt_to_access_to_private_event?(@event)
      flash[:alert] = I18n.t('pundit.not_authorized')
      return redirect_to @event
    end

    if @new_comment.save
      notify_subscribers(@event, @new_comment)
      flash[:notice] = I18n.t('controllers.comments.created')
      redirect_to @event
    else
      flash.now[:alert] = I18n.t('controllers.comments.error')
      render 'events/show'
    end
  end

  def destroy
    type, message = :notice, I18n.t('controllers.comments.destroyed')

    if current_user_can_edit?(@comment)
      @comment.destroy!
    else
      type, message = :alert, I18n.t('controllers.comments.error')
    end

    flash[type] = message
    redirect_to @event
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_comment
    @comment = @event.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body, :user_name)
  end

  def notify_subscribers(event, comment)
    all_emails = (event.subscriptions.map(&:user_email) + [event.user.email]).uniq
    all_emails -= [current_user.email] if current_user
    all_emails.each do |mail|
      EventMailer.comment(event, comment, mail).deliver_now
    end
  end
end
