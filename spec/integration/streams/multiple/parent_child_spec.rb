RSpec.describe 'multi-part parent/child relationships' do
  let(:content_id) { '8a5f749e-262c-4e4b-9d29-5da2b6349df7' }
  let(:message) do
    build :message,
          :with_parts,
          attributes: {
            'content_id' => content_id,
            'title' => 'Main Title',
            'locale' => 'fr'
          }
  end
  let(:subject) { Streams::Consumer.new }

  it 'returns the children' do
    subject.process(message)
    parent = Dimensions::Edition.find_latest("#{content_id}:fr")
    expected = [
     ["#{content_id}:fr:part2", 1],
     ["#{content_id}:fr:part3", 2],
     ["#{content_id}:fr:part4", 3]
    ]
    expect(parent.children.pluck(:warehouse_item_id, :sibling_order)).to include(*expected)
  end

  it 'resets the parent of existing unchanged items' do
    subject.process(message)
    message.payload['details']['parts'][0]['title'] = 'New title'
    message.payload["payload_version"] = message.payload["payload_version"] + 1
    subject.process(message)
    parent = Dimensions::Edition.find_latest("#{content_id}:fr")
    expected = [
      ["#{content_id}:fr:part2", 1],
      ["#{content_id}:fr:part3", 2],
      ["#{content_id}:fr:part4", 3]
    ]
    expect(parent.children.pluck(:warehouse_item_id, :sibling_order)).to include(*expected)
  end

  it 'does not reset the parent of old items' do
    old_edition = create :edition, content_id: content_id, locale: 'fr', warehouse_item_id: "#{content_id}:fr:part5"
    subject.process(message)
    message.payload['details']['parts'][0]['title'] = 'New title'
    parent = Dimensions::Edition.find_latest("#{content_id}:fr")
    expect(old_edition.reload.parent).not_to eq(parent)
  end
end
