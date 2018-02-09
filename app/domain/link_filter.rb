class LinkFilter
  attr_accessor :link_type, :source_ids, :target_ids

  def initialize(link_type:, source_ids: nil, target_ids: nil)
    self.link_type = link_type
    self.source_ids = [source_ids].flatten.compact
    self.target_ids = [target_ids].flatten.compact

    if source_ids.present? && target_ids.present?
      raise LinkFilterError, "must filter by source or target"
    end
  end

  def apply(scope)
    nested = Link.where(link_type: link_type)

    if by_source?
      nested = nested.where(source_content_id: source_ids)
      nested = nested.select("target_content_id as content_id")
    else
      nested = nested.where(target_content_id: target_ids)
      nested = nested.select("source_content_id as content_id")
    end

    scope.where(content_id: nested)
  end

  def by_source?
    source_ids.present?
  end
end

class LinkFilterError < StandardError;
end
