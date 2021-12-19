class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :events
  has_many :comments, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  validates :name, presence: true, length: {maximum: 35}
  validates :email, length: {maximum: 255}
  validates :email, uniqueness: true
  validates :email, format: /\A[a-zA-Z0-9\-_.]+@[a-zA-Z0-9\-_.]+\z/

  before_validation :set_name, on: :create
  after_commit :link_subscriptions, on: :create
  mount_uploader :avatar, AvatarUploader

  def link_subscriptions
    Subscription.where(user_id: nil, user_email: self.email).update_all(user_id: self.id)
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def self.find_for_facebook_oauth(access_token)
    email = access_token.info.email
    return nil if email.nil?

    user = find_by(email: email)
    return user if user.present?

    id = access_token.extra.raw_info.id
    url = "https://facebook.com/#{id}"
    remote_avatar_url = "#{access_token.info.image}?type=large"

    create_user_from_oauth(access_token: access_token, url: url, remote_avatar_url: remote_avatar_url)
  end

  def self.find_for_vkontakte_oauth(access_token)
    email = access_token.info.email
    return nil if email.nil?

    user = find_by(email: email)
    return user if user.present?

    url = access_token.info.urls[:Vkontakte]
    remote_avatar_url = access_token.extra.raw_info.photo_200

    create_user_from_oauth(access_token: access_token, url: url, remote_avatar_url: remote_avatar_url)
  end

  private

  def self.create_user_from_oauth(access_token:, url:, remote_avatar_url:)
    provider = access_token.provider

    where(url: url, provider: provider).first_or_create! do |user|
      user.name = access_token.info.name
      user.email =  access_token.info.email
      user.password = Devise.friendly_token.first(16)
      user.remote_avatar_url = remote_avatar_url
    end
  end

  def set_name
    self.name = "Товарисч №#{rand(777)}" if self.name.blank?
  end
end
