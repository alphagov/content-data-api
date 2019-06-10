module PublishingEventProcessingSpecHelper
  def message_attributes(overrides = {})
    {
      'payload_version' => 7,
      'locale' => 'fr',
      'title' => 'the-title',
      'document_type' => 'detailed_guide',
      'first_published_at' => '2018-04-19T12:00:40+01:00',
      'public_updated_at' => '2018-04-20T12:00:40+01:00',
      'phase' => 'live',
      'publishing_app' => 'calendars',
      'rendering_app' => 'calendars',
      'analytics_identifier' => 'analytics_identifier',
      'update_type' => 'major',
      'expanded_links' => { 'policy_areas' => [], 'primary_publishing_organisation' => primary_org },
    }.merge(overrides)
  end

  def expected_edition_attributes(overrides = {})
    {
      content_id: 'content-id-1',
      base_path: '/base-path',
      publishing_api_payload_version: 7,
      locale: 'fr',
      title: 'the-title',
      document_type: 'detailed_guide',
      first_published_at: Time.zone.parse('2018-04-19T12:00:40+01:00'),
      public_updated_at: Time.zone.parse('2018-04-20T12:00:40+01:00'),
      schema_name: 'detailed_guide',
      live: true,
      document_text: 'some content',
      phase: 'live',
      primary_organisation_id: org_content_id,
      primary_organisation_title: 'the-org',
      primary_organisation_withdrawn: false,
      organisation_ids: [],
      publishing_app: 'calendars',
      rendering_app: 'calendars',
      analytics_identifier: 'analytics_identifier',
      update_type: 'major',
    }.merge(overrides)
  end

  def expected_raw_attributes(overrides = {})
    expected_edition_attributes.merge(
      primary_organisation_withdrawn: "false",
      public_updated_at: "2018-04-20T12:00:40+01:00",
      first_published_at: "2018-04-19T12:00:40+01:00",
      withdrawn: false,
      historical: false,
      live: false
    ).merge(overrides)
  end

private

  def org_content_id
    'ce91c056-8165-49fe-b318-b71113ab4a30'
  end

  def primary_org
    [{
      'content_id' => org_content_id,
      'title' => 'the-org',
      'withdrawn' => 'false',
      'locale' => 'en',
      'base_path' => '/orgs/org-1'
    }]
  end
end
