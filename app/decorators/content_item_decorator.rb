class ContentItemDecorator < Draper::Decorator
  delegate_all

  def last_updated
    if object.public_updated_at
      "#{helpers.time_ago_in_words(object.public_updated_at)} ago"
    else
      "Never"
    end
  end

  def organisation_links
    names = object.organisations.collect do |organisation|
      helpers.link_to(organisation.title, helpers.content_items_path(organisation_slug: organisation.slug))
    end

    names.join(', ').html_safe
  end

  def taxons_as_string
    object.taxonomies.map(&:title).join(', ')
  end
end
