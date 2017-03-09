class ContentItemDecorator < Draper::Decorator
  delegate_all

  def last_updated
    if object.public_updated_at
      "#{helpers.time_ago_in_words(object.public_updated_at)} ago"
    else
      "Never"
    end
  end
end
