require 'rails_helper'

RSpec.describe EventPolicy do
  subject { described_class }

  let(:user) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:user) }

  let(:event) { FactoryBot.create(:event, user: user) }
  let(:event_with_pincode) { FactoryBot.create(:event, user: user, pincode: '1234') }

  let(:valid_cookies) { { "events_#{event_with_pincode.id}_pincode" => '1234' } }

  let(:user_context) { UserContext.new(user, {}) }
  let(:other_user_w_o_private_access_context) { UserContext.new(other_user, {}) }
  let(:guest_w_private_access_context) { UserContext.new(nil, valid_cookies) }

  context 'User try to edit, update or destroy event' do
    context 'when user is owner' do
      permissions :edit?, :update?, :destroy? do
        it { is_expected.to permit(user_context, event) }
      end
    end

    context 'when user is not owner' do
      permissions :edit?, :update?, :destroy? do
        it { is_expected.not_to permit(other_user_w_o_private_access_context, event) }
      end
    end

    context 'when user is not authentificated' do
      permissions :edit?, :update?, :destroy? do
        it { is_expected.not_to permit(guest_w_private_access_context, event) }
      end
    end
  end

  context 'User try to look event' do
    context 'when pincode is absent' do
      permissions :show? do
        it { is_expected.to permit(other_user_w_o_private_access_context, event) }
      end
    end

    context 'when pincode is present' do
      context 'and user is owner' do
        permissions :show? do
          it { is_expected.to permit(user_context, event_with_pincode) }
        end
      end

      context 'and user has valid cookies' do
        permissions :show? do
          it { is_expected.to permit(guest_w_private_access_context, event_with_pincode) }
        end
      end

      context 'and user has not valid cookies' do
        permissions :show? do
          it { is_expected.not_to permit(other_user_w_o_private_access_context, event_with_pincode) }
        end
      end
    end
  end
end
