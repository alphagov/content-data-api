class LinkFactory
  def self.add_organisations(content_item, organisations)
    add_links(content_item, organisations, Link::ALL_ORGS)
  end

  def self.add_parent(content_item, parent)
    add_links(content_item, parent, Link::PARENT)
  end

  def self.add_primary_publishing_organisation(content_item, organisation)
    add_organisations(content_item, organisation)
    add_link(content_item, organisation, Link::PRIMARY_ORG)
  end

  def self.add_policies(content_item, policies)
    add_links(content_item, policies, Link::POLICIES)
  end

  def self.add_policy_areas(content_item, policy_areas)
    add_links(content_item, policy_areas, Link::POLICY_AREAS)
  end

  def self.add_topics(content_item, topics)
    add_links(content_item, topics, Link::TOPICS)
  end

  def self.add_link(content_item, target, link_type)
    return unless target

    FactoryBot.create(
      :link,
      source: content_item,
      target: target,
      link_type: link_type,
    )
  end

  def self.add_links(content_item, targets, link_type)
    return unless targets

    [targets].flatten.each do |target|
      add_link(content_item, target, link_type)
    end
  end
end
