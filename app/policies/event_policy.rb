class EventPolicy < ApplicationPolicy
  def destroy?
    update?
  end

  def edit?
    update?
  end

  def update?
    user_is_owner?(record)
  end

  def show?
    user_can_look?(record)
  end

  private

  def user_is_owner?(event)
    user.present? && (event.try(:user) == user)
  end

  def user_can_look?(event)
    event.pincode.blank? ||
    (user.present? && (event.try(:user) == user)) ||
    event.pincode_valid?(cookies["events_#{event.id}_pincode"])
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
