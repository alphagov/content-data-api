require "govuk_message_queue_consumer/test_helpers"

def expect_messages_to_have_publishing_api_events(messages)
  expected_messages = messages.map do |message|
    have_attributes(
      routing_key: message.delivery_info["routing_key"],
      payload: message.payload,
    )
  end
  expect(Events::PublishingApi.all).to contain_exactly(*expected_messages)
end

RSpec.describe "PublishingAPI message queue" do
  include PublishingEventProcessingSpecHelper

  let(:subject) { Streams::Consumer.new }

  it "publishes new edition for new content item" do
    expect(GovukStatsd).to receive(:increment)
      .with("monitor.messages.major")

    message = build :message
    subject.process(message)

    expect(Dimensions::Edition.all).to contain_exactly(
      have_attributes(
        warehouse_item_id: "#{message.payload['content_id']}:en",
        base_path: "/base-path",
        live: true,
      ),
    )

    expect_messages_to_have_publishing_api_events([message])
    expect(message).to be_acked
  end

  it "publishes multiple editions for a content item" do
    expect(GovukStatsd).to receive(:increment)
      .with("monitor.messages.major").twice

    message1 = build :message
    subject.process(message1)

    content_id = message1.payload["content_id"]

    message2 = build :message, content_id: content_id
    subject.process(message2)

    expect(Dimensions::Edition.all).to contain_exactly(
      have_attributes(
        warehouse_item_id: "#{content_id}:en",
        base_path: "/base-path",
        live: false,
      ),
      have_attributes(
        warehouse_item_id: "#{content_id}:en",
        base_path: "/base-path",
        live: true,
      ),
    )

    expect_messages_to_have_publishing_api_events([message1, message2])
    expect(message1).to be_acked
    expect(message2).to be_acked
  end

  it "republishes same edition for content item" do
    expect(GovukStatsd).to receive(:increment)
      .with("monitor.messages.major").twice

    message = build :message
    subject.process(message)
    subject.process(message)

    content_id = message.payload["content_id"]

    expect(Dimensions::Edition.all).to contain_exactly(
      have_attributes(
        warehouse_item_id: "#{content_id}:en",
        base_path: "/base-path",
        live: true,
      ),
    )

    expect_messages_to_have_publishing_api_events([message])
    expect(message).to be_acked
  end

  it "sends an old publishing message" do
    expect(GovukStatsd).to receive(:increment)
      .with("monitor.messages.major").twice

    message = build :message, attributes: { "payload_version" => 2 }
    subject.process(message)

    content_id = message.payload["content_id"]

    old_message = build :message, content_id: content_id, attributes: { "payload_version" => 1 }
    subject.process(old_message)

    expect(Dimensions::Edition.all).to contain_exactly(
      have_attributes(
        warehouse_item_id: "#{content_id}:en",
        base_path: "/base-path",
        live: true,
      ),
    )

    expect_messages_to_have_publishing_api_events([message])
    expect(message).to be_acked
    expect(old_message).to be_acked
  end

  it "unpublishes edition for content item" do
    expect(GovukStatsd).to receive(:increment)
     .with("monitor.messages.major").twice

    message = build :message
    subject.process(message)

    content_id = message.payload["content_id"]

    gone_message = build :gone_message, content_id: content_id
    subject.process(gone_message)

    expect(Dimensions::Edition.all).to contain_exactly(
      have_attributes(
        warehouse_item_id: "#{content_id}:en",
        base_path: "/base-path",
        live: false,
        schema_name: "gone",
      ),
      have_attributes(
        warehouse_item_id: "#{content_id}:en",
        base_path: "/base-path",
        live: false,
      ),
    )

    expect_messages_to_have_publishing_api_events([message, gone_message])
    expect(message).to be_acked
    expect(gone_message).to be_acked
  end

  it "twice unpublishes edition for content item" do
    expect(GovukStatsd).to receive(:increment)
      .with("monitor.messages.major").exactly(3).times

    message = build :message
    subject.process(message)

    content_id = message.payload["content_id"]

    gone_message1 = build :gone_message, content_id: content_id
    subject.process(gone_message1)

    gone_message2 = build :gone_message, content_id: content_id
    subject.process(gone_message2)

    expect(Dimensions::Edition.all).to contain_exactly(
      have_attributes(
        warehouse_item_id: "#{content_id}:en",
        base_path: "/base-path",
        live: false,
        schema_name: "gone",
      ),
      have_attributes(
        warehouse_item_id: "#{content_id}:en",
        base_path: "/base-path",
        live: false,
      ),
    )

    expect_messages_to_have_publishing_api_events([message, gone_message1])
    expect(message).to be_acked
    expect(gone_message1).to be_acked
    expect(gone_message2).to be_acked
  end

  it "publishes redirect edition for content item" do
    expect(GovukStatsd).to receive(:increment)
     .with("monitor.messages.major").twice

    message = build :message
    subject.process(message)

    content_id = message.payload["content_id"]

    redirect_message = build :redirect_message, content_id: content_id
    subject.process(redirect_message)

    expect(Dimensions::Edition.all).to contain_exactly(
      have_attributes(
        warehouse_item_id: "#{content_id}:en",
        base_path: "/base-path",
        live: false,
        schema_name: "redirect",
      ),
      have_attributes(
        warehouse_item_id: "#{content_id}:en",
        base_path: "/base-path",
        live: false,
      ),
    )

    expect_messages_to_have_publishing_api_events([message, redirect_message])
    expect(message).to be_acked
    expect(redirect_message).to be_acked
  end

  it "publishes edition with new base_path for content item" do
    expect(GovukStatsd).to receive(:increment)
      .with("monitor.messages.major").twice

    message1 = build :message
    subject.process(message1)

    content_id = message1.payload["content_id"]

    message2 = build :message, content_id: content_id, base_path: "/base-path-2"
    subject.process(message2)

    expect(Dimensions::Edition.all).to contain_exactly(
      have_attributes(
        warehouse_item_id: "#{content_id}:en",
        base_path: "/base-path",
        live: false,
      ),
      have_attributes(
        warehouse_item_id: "#{content_id}:en",
        base_path: "/base-path-2",
        live: true,
      ),
    )

    expect_messages_to_have_publishing_api_events([message1, message2])
    expect(message1).to be_acked
    expect(message2).to be_acked
  end

  it "publishes new content item using base path of previously unpublished content item" do
    expect(GovukStatsd).to receive(:increment)
      .with("monitor.messages.major").exactly(3).times

    message1 = build :message
    subject.process(message1)

    content_id = message1.payload["content_id"]

    gone_message = build :gone_message, content_id: content_id
    subject.process(gone_message)

    message2 = build :message
    subject.process(message2)

    content_id2 = message2.payload["content_id"]

    expect(Dimensions::Edition.all).to contain_exactly(
      have_attributes(
        warehouse_item_id: "#{content_id}:en",
        base_path: "/base-path",
        live: false,
      ),
      have_attributes(
        warehouse_item_id: "#{content_id}:en",
        base_path: "/base-path",
        live: false,
        schema_name: "gone",
      ),
      have_attributes(
        warehouse_item_id: "#{content_id2}:en",
        base_path: "/base-path",
        live: true,
      ),
    )

    expect_messages_to_have_publishing_api_events([message1, gone_message, message2])
    expect(message1).to be_acked
    expect(gone_message).to be_acked
    expect(message2).to be_acked
  end

  it "remains unpublished even when it receives RepresentDownstream event" do
    build_message = build :message
    subject.process(build_message)

    content_id = build_message.payload["content_id"]

    gone_message = build :gone_message, content_id: content_id
    subject.process(gone_message)

    # rubocop:disable Layout/SpaceInsideHashLiteralBraces, Layout/SpaceAroundOperators, Style/WordArray, Lint/MissingCopEnableDirective, Style/NumericLiterals
    represent_downstream_message = build(
      :message,
      content_id: content_id,
      routing_key: "html_publication.links",
      # The following payload was taken from Production by running:
      # `Dimensions::Edition.where(content_id: "b6a2a286-8669-4cbe-a4ad-7997608598d2").last.publishing_api_event`
      payload: {"links"=>{"parent"=>["5e970b04-7631-11e4-a3cb-005056011aef"], "organisations"=>["d994e55c-48c9-4795-b872-58d8ec98af12", "73833cda-22ca-4711-87f9-73a98814315d"]}, "phase"=>"live", "title"=>"British Forces Post Office: last dates of posting for Christmas", "locale"=>"en", "routes"=>[{"path"=>"/government/publications/british-forces-post-office-last-dates-of-posting/british-forces-post-office-last-dates-of-posting-for-christmas", "type"=>"exact"}], "details"=>{"body"=>"<div class=\"govspeak\"><p>2017 last dates of posting Christmas will be published in October.</p></div>", "headings"=>"<ol></ol>", "public_timestamp"=>"2016-10-03T12:36:22.000+01:00", "first_published_version"=>false}, "base_path"=>"/government/publications/british-forces-post-office-last-dates-of-posting/british-forces-post-office-last-dates-of-posting-for-christmas", "redirects"=>[], "content_id"=>"b6a2a286-8669-4cbe-a4ad-7997608598d2", "description"=>nil, "schema_name"=>"html_publication", "update_type"=>nil, "document_type"=>"html_publication", "rendering_app"=>"government-frontend", "expanded_links"=>{"parent"=>[{"links"=>{"parent"=>[{"links"=>{"parent"=>[{"links"=>{}, "title"=>"Defence and armed forces", "locale"=>"en", "api_path"=>"/api/content/topic/defence-armed-forces", "base_path"=>"/topic/defence-armed-forces", "withdrawn"=>false, "content_id"=>"cc902c81-79b6-4289-aa5a-1805923cbe06", "schema_name"=>"topic", "document_type"=>"topic", "public_updated_at"=>"2015-08-11T14:45:19Z", "analytics_identifier"=>nil}]}, "title"=>"Support services for military and defence personnel and their families", "locale"=>"en", "api_path"=>"/api/content/topic/defence-armed-forces/support-services-military-defence-personnel-families", "base_path"=>"/topic/defence-armed-forces/support-services-military-defence-personnel-families", "withdrawn"=>false, "content_id"=>"045fa48e-f96c-4160-8a97-680f32cf1e91", "schema_name"=>"topic", "document_type"=>"topic", "public_updated_at"=>"2017-03-20T11:23:54Z", "analytics_identifier"=>nil}]}, "title"=>"British Forces Post Office: last dates of posting", "locale"=>"en", "api_path"=>"/api/content/government/publications/british-forces-post-office-last-dates-of-posting", "base_path"=>"/government/publications/british-forces-post-office-last-dates-of-posting", "withdrawn"=>false, "content_id"=>"5e970b04-7631-11e4-a3cb-005056011aef", "schema_name"=>"publication", "document_type"=>"guidance", "public_updated_at"=>"2020-07-03T14:27:53Z", "analytics_identifier"=>nil}], "organisations"=>[{"links"=>{}, "title"=>"Ministry of Defence", "locale"=>"en", "details"=>{"logo"=>{"crest"=>"mod", "formatted_title"=>"Ministry<br/>of Defence"}, "brand"=>"ministry-of-defence", "default_news_image"=>{"url"=>"https://assets.publishing.service.gov.uk/government/uploads/system/uploads/default_news_organisation_image_data/file/154/s300_ministry-of-defence.jpg", "high_resolution_url"=>"https://assets.publishing.service.gov.uk/government/uploads/system/uploads/default_news_organisation_image_data/file/154/s960_ministry-of-defence.jpg"}, "organisation_govuk_status"=>{"url"=>nil, "status"=>"live", "updated_at"=>nil}}, "api_path"=>"/api/content/government/organisations/ministry-of-defence", "base_path"=>"/government/organisations/ministry-of-defence", "withdrawn"=>false, "content_id"=>"d994e55c-48c9-4795-b872-58d8ec98af12", "schema_name"=>"organisation", "document_type"=>"organisation", "analytics_identifier"=>"D17"}, {"links"=>{}, "title"=>"Defence Equipment and Support", "locale"=>"en", "details"=>{"logo"=>{"formatted_title"=>"Defence Equipment <br/>and Support"}, "brand"=>"ministry-of-defence", "default_news_image"=>nil, "organisation_govuk_status"=>{"url"=>nil, "status"=>"live", "updated_at"=>nil}}, "api_path"=>"/api/content/government/organisations/defence-equipment-and-support", "base_path"=>"/government/organisations/defence-equipment-and-support", "withdrawn"=>false, "content_id"=>"73833cda-22ca-4711-87f9-73a98814315d", "schema_name"=>"organisation", "document_type"=>"organisation", "analytics_identifier"=>"OT495"}]}, "publishing_app"=>"whitehall", "payload_version"=>33755430, "govuk_request_id"=>"20791-1593786345.505-10.13.1.157-2094", "public_updated_at"=>"2017-01-04T11:50:27Z", "first_published_at"=>"2017-01-04T11:56:58Z", "analytics_identifier"=>nil, "content_purpose_subgroup"=>"other", "email_document_supertype"=>"other", "content_purpose_supergroup"=>"other", "government_document_supertype"=>"other", "navigation_document_supertype"=>"other", "user_journey_document_supertype"=>"thing", "content_purpose_document_supertype"=>"guidance", "search_user_need_document_supertype"=>"government"},
    )
    # rubocop:enable
    subject.process(represent_downstream_message)

    expect(Dimensions::Edition.count).to eq(2)
    expect(Dimensions::Edition.first).to have_attributes(
      warehouse_item_id: "#{content_id}:en",
      base_path: "/base-path",
      live: false,
    )
    expect(Dimensions::Edition.last).to have_attributes(
      warehouse_item_id: "#{content_id}:en",
      base_path: "/base-path",
      live: false,
      schema_name: "gone",
    )

    expect_messages_to_have_publishing_api_events([build_message, gone_message, represent_downstream_message])
    expect(build_message).to be_acked
    expect(gone_message).to be_acked
    expect(represent_downstream_message).to be_acked
  end
end
