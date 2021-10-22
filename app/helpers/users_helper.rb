module UsersHelper
  def user_avatar(user)
    return user.avatar.url if user.avatar?
    asset_url('user.png')
  end

  def user_avatar_thumb(user)
    return user.avatar.thumb.url if user.avatar.file.present?
    asset_url('user.png')
  end
end
