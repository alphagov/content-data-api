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

  it 'returns the children sorted by sort order' do
    subject.process(message)
    parent = Dimensions::Edition.find_latest("#{content_id}:fr")
    expected = [
     ["#{content_id}:fr:part2", 1],
     ["#{content_id}:fr:part3", 2],
     ["#{content_id}:fr:part4", 3]
    ]
    expect(parent.children.pluck(:warehouse_item_id, :sibling_order)).to eq(expected)
  end
end
