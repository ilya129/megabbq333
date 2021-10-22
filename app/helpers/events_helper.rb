module EventsHelper
  def event_photo(event)
    photos = event.photos.persisted

    return photos.sample.photo.url if photos.any?
    asset_url('event.jpg')
  end

  def event_thumb(event)
    photos = event.photos.persisted

    return photos.sample.photo.thumb.url if photos.any?
    asset_url('event_thumb.jpg')
  end
end
