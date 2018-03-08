require 'rails_helper'

RSpec.describe Dimensions::Item, type: :model do
  it { is_expected.to validate_presence_of(:content_id) }

  describe "#get_content" do
    it "returns nil if json is empty" do
      item = create(:dimensions_item, raw_json: {})
      expect(item.get_content).to eq(nil)
    end

    context "when valid schema" do
      it "returns content json if details.body exists" do
        json = build_raw_json(body: 'the-body')

        item = create(:dimensions_item, raw_json: json)
        expect(item.get_content).to eq('the-body')
      end

      it 'returns nil if details.body does NOT exist' do
        valid_schema_json = { schema_name: 'answer', details: {} }
        item = create(:dimensions_item, raw_json: valid_schema_json)
        expect(item.get_content).to eq(nil)
      end

      it 'does not fail with unicode characters' do
        json = build_raw_json(body: %{\u003cdiv class="govspeak"\u003e\u003cp\u003eLorem ipsum dolor sit amet.})

        item = create(:dimensions_item, raw_json: json)
        expect(item.get_content).to eq('Lorem ipsum dolor sit amet.')
      end

      it "returns content json if schema is 'licence'" do
        json = { schema_name: 'licence',
          details: { licence_overview: 'licence expired' } }
        item = create(:dimensions_item, raw_json: json)
        expect(item.get_content).to eq('licence expired')
      end

      it "returns content json if schema is 'place'" do
        json = { schema_name: 'place',
          details: { introduction: 'Introduction',
            more_information: 'Enter your postcode' } }
        item = create(:dimensions_item, raw_json: json)
        expect(item.get_content).to eq('Introduction Enter your postcode')
      end

      it "returns content json if schema_name is 'guide'" do
        json = { schema_name: 'guide',
          details: { parts:
            [{ title: 'Schools',
              body: 'Local council' },
             { title: 'Appeal',
               body: 'No placement' }] } }
        item = create(:dimensions_item, raw_json: json)
        expect(item.get_content).to eq('Schools Local council Appeal No placement')
      end

      it "returns content json if schema_name is 'transaction'" do
        json = { schema_name: "transaction",
          details: { introductory_paragraph: "Report changes",
                    start_button_text: "Start",
                    will_continue_on: "Carer's Allowance service",
                    more_information: "Facts" } }
        item = create(:dimensions_item, raw_json: json)
        expected = "Report changes Start Carer's Allowance service Facts"
        expect(item.get_content).to eq(expected)
      end

      it "returns content json if schema_name is 'email_alert_signup'" do
        json = { schema_name: "email_alert_signup",
          details: { breadcrumbs: [{ title: "The title" }],
                     summary: "Summary" } }
        item = create(:dimensions_item, raw_json: json)
        expect(item.get_content).to eq("The title Summary")
      end

      it "returns content json if schema_name is 'finder_email_signup'" do
        json = { schema_name: "finder_email_signup",
                 description: "Use buttons",
                 details: { email_signup_choice:
                   [{ radio_button_name: "Yes" },
                    { radio_button_name: "No" }] } }
        item = create(:dimensions_item, raw_json: json)
        expect(item.get_content).to eq("Yes No Use buttons")
      end

      it "returns content json if schema_name is 'location_transaction'" do
        json = { schema_name: "location_transaction",
                 details: { introduction: "Greetings", need_to_know: "A Name",
                            more_information: "An Address" } }
        item = create(:dimensions_item, raw_json: json)
        expect(item.get_content).to eq("Greetings A Name An Address")
      end

      it "returns content json if schema_name is 'service_manual_topic'" do
        json = { schema_name: "service_manual_topic",
                 description: "Blogs",
                 details: { groups: [{ name: "Design",
                                       description: "thinking" },
                                     { name: "Performance",
                                       description: "analysis" }] } }
        item = create(:dimensions_item, raw_json: json)
        expect(item.get_content).to eq("Blogs Design thinking Performance analysis")
      end

      def build_raw_json(body:)
        {
          schema_name: :detailed_guide,
          details: {
            body: body
          }
        }
      end
    end

    context 'when invalid schema' do
      it 'raise InvalidSchemaError if json schema_name is not known' do
        no_schema_json = { schema_name: 'blah' }
        item = create(:dimensions_item, raw_json: no_schema_json)
        expect { item.get_content }.to raise_error(InvalidSchemaError)
      end

      it 'raises InvalidSchemaError if non-empty json does not have a schema_name' do
        invalid_schema = { document_type: 'answer' }
        item = create(:dimensions_item, raw_json: invalid_schema)
        expect { item.get_content }.to raise_error(InvalidSchemaError)
      end
    end
  end

  describe '.dirty_before' do
    let(:date) { Date.new(2018, 2, 2) }
    it 'returns the dirty items updated before the given date' do
      expected_item = create(:dimensions_item, dirty: true, updated_at: Time.utc(2018, 2, 1, 23, 59, 59))
      create(:dimensions_item, dirty: true, updated_at: Time.utc(2018, 2, 2))
      expect(Dimensions::Item.dirty_before(date)).to match_array(expected_item)
    end
  end

  describe '#new_version' do
    it 'duplicates the old item with latest: true, dirty: false but does not save' do
      old_item = build(:dimensions_item,
        dirty: true,
        latest: true,
        raw_json: { 'the' => 'content' },
        content_id: 'c-id',
        base_path: '/the/path')
      new_version = old_item.new_version
      expect(new_version).to have_attributes(
        dirty: false,
        latest: true,
        raw_json: { 'the' => 'content' },
        content_id: 'c-id',
        base_path: '/the/path'
      )
      expect(new_version.new_record?).to eq(true)
    end
  end

  describe '#dirty!' do
    it 'sets the dirty? flag to true' do
      item = create(:dimensions_item, dirty: false)
      item.dirty!
      expect(item.reload.dirty?).to be true
    end
  end

  describe '#gone!' do
    it 'sets the status to "gone"' do
      item = create(:dimensions_item, dirty: false)
      item.gone!
      expect(item.reload.status).to eq 'gone'
    end
  end

  it 'stores/read a Hash with the item JSON' do
    item = create :dimensions_item, raw_json: { a: :b }
    item.reload

    expect(item.raw_json).to eq('a' => 'b')
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
