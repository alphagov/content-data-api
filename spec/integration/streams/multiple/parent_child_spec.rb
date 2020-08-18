RSpec.describe "multi-part parent/child relationships" do
  # FIXME: Rails 6 inconsistently overrides ActiveJob queue_adapter setting
  # with TestAdapter #37270
  # See https://github.com/rails/rails/issues/37270
  around do |example|
    perform_enqueued_jobs { example.run }
  end

  let(:content_id) { "8a5f749e-262c-4e4b-9d29-5da2b6349df7" }
  let(:message) do
    build :message,
          :with_parts,
          attributes: {
            "content_id" => content_id,
            "title" => "Main Title",
            "locale" => "fr",
          }
  end
  let(:subject) { Streams::Consumer.new }

  it "returns the children" do
    subject.process(message)
    parent = Dimensions::Edition.find_latest("#{content_id}:fr")
    expected = [
      ["#{content_id}:fr:part2", 1],
      ["#{content_id}:fr:part3", 2],
      ["#{content_id}:fr:part4", 3],
    ]
    expect(parent.children.pluck(:warehouse_item_id, :sibling_order)).to include(*expected)
  end

  it "resets the parent of existing unchanged items" do
    subject.process(message)
    message.payload["details"]["parts"][0]["title"] = "New title"
    message.payload["payload_version"] = message.payload["payload_version"] + 1
    subject.process(message)
    parent = Dimensions::Edition.find_latest("#{content_id}:fr")
    expected = [
      ["#{content_id}:fr:part2", 1],
      ["#{content_id}:fr:part3", 2],
      ["#{content_id}:fr:part4", 3],
    ]
    expect(parent.children.pluck(:warehouse_item_id, :sibling_order)).to include(*expected)
  end

  it "does not reset the parent of old items" do
    old_edition = create :edition, content_id: content_id, locale: "fr", warehouse_item_id: "#{content_id}:fr:part5"
    subject.process(message)
    message.payload["details"]["parts"][0]["title"] = "New title"
    parent = Dimensions::Edition.find_latest("#{content_id}:fr")
    expect(old_edition.reload.parent).not_to eq(parent)
  end

  it "populates the relationship information for new content item" do
    subject.process(message)

    editions = Dimensions::Edition.all.pluck(:warehouse_item_id, :title, :sibling_order, :parent_id, :live)
    parent_id = Dimensions::Edition.where(title: "Main Title: Part 1").first.id

    expect(editions).to include(
      ["#{content_id}:fr", "Main Title: Part 1", 0, nil, true],
      ["#{content_id}:fr:part2", "Main Title: Part 2", 1, parent_id, true],
      ["#{content_id}:fr:part3", "Main Title: Part 3", 2, parent_id, true],
      ["#{content_id}:fr:part4", "Main Title: Part 4", 3, parent_id, true],
    )
  end

  it "populates the relationship information for updating all parts of an existing content item" do
    subject.process(message)
    new_message = build(:message, :with_parts, attributes: { "content_id" => content_id, "title" => "New Title", "locale" => "fr" })
    subject.process(new_message)

    editions = Dimensions::Edition.all.pluck(:warehouse_item_id, :title, :sibling_order, :parent_id, :live)
    new_parent_id = Dimensions::Edition.where(title: "New Title: Part 1").first.id

    expect(editions).to include(
      ["#{content_id}:fr", "Main Title: Part 1", 0, nil, false],
      ["#{content_id}:fr:part2", "Main Title: Part 2", 1, new_parent_id, false],
      ["#{content_id}:fr:part3", "Main Title: Part 3", 2, new_parent_id, false],
      ["#{content_id}:fr:part4", "Main Title: Part 4", 3, new_parent_id, false],
      ["#{content_id}:fr", "New Title: Part 1", 0, nil, true],
      ["#{content_id}:fr:part2", "New Title: Part 2", 1, new_parent_id, true],
      ["#{content_id}:fr:part3", "New Title: Part 3", 2, new_parent_id, true],
      ["#{content_id}:fr:part4", "New Title: Part 4", 3, new_parent_id, true],
    )
  end

  it "populates the relationship information for updating a single child of an existing content item" do
    subject.process(message)

    new_message = message
    new_message.payload["details"]["parts"][1]["title"] = "New section"
    new_message.payload["payload_version"] += 1
    subject.process(new_message)

    editions = Dimensions::Edition.all.pluck(:warehouse_item_id, :title, :sibling_order, :parent_id, :live)
    parent_id = Dimensions::Edition.where(title: "Main Title: Part 1").first.id

    expect(editions).to include(
      ["#{content_id}:fr", "Main Title: Part 1", 0, nil, true],
      ["#{content_id}:fr:part2", "Main Title: Part 2", 1, parent_id, false],
      ["#{content_id}:fr:part3", "Main Title: Part 3", 2, parent_id, true],
      ["#{content_id}:fr:part4", "Main Title: Part 4", 3, parent_id, true],
      ["#{content_id}:fr:part2", "Main Title: New section", 1, parent_id, true],
    )
  end

  it "populates the relationship information for updating only the parent of an existing content item" do
    subject.process(message)

    new_message = message
    new_message.payload["details"]["parts"][0]["title"] = "New parent"
    new_message.payload["payload_version"] += 1
    subject.process(new_message)

    editions = Dimensions::Edition.all.pluck(:warehouse_item_id, :title, :sibling_order, :parent_id, :live)
    parent_id = Dimensions::Edition.where(title: "Main Title: New parent").first.id

    expect(editions).to include(
      ["#{content_id}:fr", "Main Title: Part 1", 0, nil, false],
      ["#{content_id}:fr:part2", "Main Title: Part 2", 1, parent_id, true],
      ["#{content_id}:fr:part3", "Main Title: Part 3", 2, parent_id, true],
      ["#{content_id}:fr:part4", "Main Title: Part 4", 3, parent_id, true],
      ["#{content_id}:fr", "Main Title: New parent", 0, nil, true],
    )
  end
end
