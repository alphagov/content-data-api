class ItemDecorator < Draper::Decorator
  delegate_all

  def last_updated
    h.format_datetime(public_updated_at)
  end

  def feedex_link
    helpers.link_to "View feedback on FeedEx", "#{Plek.new.external_url_for('support')}/anonymous_feedback?path=#{object.base_path}"
  end

  def organisation_links
    names = object.linked_organisations.collect do |organisation|
      helpers.link_to(organisation.title, helpers.item_path(organisation.content_id))
    end

    names.join(', ').html_safe
  end

  def taxons_as_string
    object.linked_taxons.map(&:title).join(', ')
  end

  def organisations
    titles(object.linked_organisations)
  end

  def policy_areas
    titles(object.linked_policy_areas)
  end

  def guidance
    h.format_boolean(guidance?)
  end

  def withdrawn
    h.format_boolean(withdrawn?)
  end

  def one_month_page_views
    h.format_number(object.one_month_page_views)
  end

  def six_months_page_views
    h.format_number(object.six_months_page_views)
  end

  def document_type
    object.document_type.titleize
  end

private

  def titles(content_items)
    h.format_array(content_items.map(&:title).sort)
  end
end
