RSpec.describe 'setting parents for manuals' do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  let(:manual_message) do
    build :message,
          base_path: '/manual',
          schema_name: 'manual',
          attributes: { 'document_type' => 'manual' }
  end

  let(:section_1_message) do
    build :message,
          base_path: '/manual/section-1',
          schema_name: 'manual_section',
          attributes: { 'document_type' => 'manual_section' }
  end

  let(:section_2_message) do
    build :message,
          base_path: '/manual/section-2',
          schema_name: 'manual_section',
          attributes: { 'document_type' => 'manual_section' }
  end
  let(:links_for_parent) do
    {
      'sections' => [section_1_message, section_2_message].map do |message|
        { 'content_id' => message.payload['content_id'], 'locale' => message.payload['locale'] }
      end
    }
  end
  let(:links_for_child) do
    { 'manual' => [{
      'content_id' => manual_message.payload['content_id'],
      'locale' => manual_message.payload['locale']
    }] }
  end

  subject { Streams::Consumer.new }

  before do
    manual_message.payload['expanded_links'] = links_for_parent
    section_1_message.payload['expanded_links'] = links_for_child
    section_2_message.payload['expanded_links'] = links_for_child
  end

  context 'when the manual arrives first' do
    before do
      subject.process(manual_message)
      subject.process(section_2_message)
      subject.process(section_1_message)
    end

    it 'sets the parents correctly' do
      manual_warehouse_id = "#{manual_message.payload['content_id']}:#{manual_message.payload['locale']}"
      manual = Dimensions::Edition.where(warehouse_item_id: manual_warehouse_id).first
      expected = [
        ["#{section_1_message.payload['content_id']}:#{section_1_message.payload['locale']}", 1],
        ["#{section_2_message.payload['content_id']}:#{section_2_message.payload['locale']}", 2]
      ]
      expect(manual.children.order(:sibling_order).pluck(:warehouse_item_id, :sibling_order)).to eq(expected)
    end
  end

  context 'when the sections arrive first' do
    before do
      subject.process(section_2_message)
      subject.process(section_1_message)
      subject.process(manual_message)
    end

    it 'sets the parents correctly' do
      manual_warehouse_id = "#{manual_message.payload['content_id']}:#{manual_message.payload['locale']}"
      manual = Dimensions::Edition.where(warehouse_item_id: manual_warehouse_id).first
      expected = [
        ["#{section_1_message.payload['content_id']}:#{section_1_message.payload['locale']}", 1],
        ["#{section_2_message.payload['content_id']}:#{section_2_message.payload['locale']}", 2]
      ]
      expect(manual.children.order(:sibling_order).pluck(:warehouse_item_id, :sibling_order)).to eq(expected)
    end
  end
end
