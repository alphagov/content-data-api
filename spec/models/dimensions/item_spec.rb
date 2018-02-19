require 'rails_helper'

RSpec.describe Dimensions::Item, type: :model do
  let(:test_json) do
    {
      schema_name: "answer",
      details: {
        body: "This is a test"
      }
    }.to_json
  end

  it { is_expected.to validate_presence_of(:content_id) }

  describe "#get_content" do
    it "returns nil if json is empty" do
      item = create(:dimensions_item, raw_json: {}.to_json)
      expect(item.get_content).to eq(nil)
    end

    context "when valid schema" do
      it "returns content json if details.body exists" do
        json = build_raw_json(body: 'the-body')

        item = create(:dimensions_item, raw_json: json)
        expect(item.get_content).to eq('the-body')
      end

      it "returns nil if details.body does NOT exist" do
        valid_schema_json = { schema_name: "answer", details: {} }.to_json
        item = create(:dimensions_item, raw_json: valid_schema_json)
        expect(item.get_content).to eq(nil)
      end

      it "does not fail with unicode characters" do
        json = build_raw_json(body: %{\u003cdiv class="govspeak"\u003e\u003cp\u003eLorem ipsum dolor sit amet.})

        item = create(:dimensions_item, raw_json: json)
        expect(item.get_content).to eq("Lorem ipsum dolor sit amet.")
      end

      def build_raw_json(body:)
        {
          schema_name: :detailed_guide,
          details: {
            body: body
          }
        }.to_json
      end
    end

    context "when invalid schema" do
      it "raise InvalidSchemaError if json schema_name is not known" do
        no_schema_json = { schema_name: "blah" }.to_json
        item = create(:dimensions_item, raw_json: no_schema_json)
        expect { item.get_content }.to raise_error(InvalidSchemaError)
      end

      it "raises InvalidSchemaError if non-empty json does not have a schema_name" do
        invalid_schema = { document_type: "answer" }.to_json
        item = create(:dimensions_item, raw_json: invalid_schema)
        expect { item.get_content }.to raise_error(InvalidSchemaError)
      end
    end
  end

  describe '.dirty' do
    it 'only returns the dirty items' do
      dirty_item = create(:dimensions_item, dirty: true)
      create(:dimensions_item, dirty: false)

      expect(Dimensions::Item.dirty).to match_array(dirty_item)
    end
  end

  describe '#dirty' do
     # todo
  end

  describe '#new_version!' do
    let(:dirty_item) { create(:dimensions_item, dirty: true, latest: true) }

    it 'duplicates the item with latest?: true, dirty?: false' do
      new_item = dirty_item.new_version!

      expect(new_item).to have_attributes(
        latest: true,
        dirty: false
      )
    end

    it 'sets latest? and dirty? to false on the old item' do
      dirty_item.new_version!

      expect(dirty_item.reload).to have_attributes(
        latest: false,
        dirty: false
      )
    end
  end

  describe '#dirty!' do
    it 'sets the dirty? flag to true' do
      item = create(:dimensions_item, dirty: false)
      item.dirty!
      expect(item.reload.dirty?).to be true
    end
  end

  describe '##create_empty' do
    let(:content_id) { 'new-item' }
    let(:base_path) { '/path/to/new-item' }
    it 'creates a new item with the correct attributes' do
      item = Dimensions::Item.create_empty content_id, base_path
      expect(item.reload).to have_attributes(
        content_id: content_id,
        base_path: base_path,
        dirty: true,
        latest: true
      )
    end
  end
end
