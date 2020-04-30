RSpec.describe Streams::GrowDimension do
  describe ".should_grow?" do
    let(:edition) { create :edition, publishing_api_payload_version: 4 }
    let(:new_attrs) do
      {
        document_text: "new text",
        publishing_api_payload_version: "5",
      }
    end
    subject { described_class }

    it "returns true if the content has changed" do
      expect(subject.should_grow?(
               old_edition: edition,
               attrs: new_attrs,
             )).to eq(true)
    end

    it "returns false if payload version is the same" do
      expect(subject.should_grow?(
               old_edition: edition,
               attrs: new_attrs.merge(publishing_api_payload_version: "4"),
             )).to eq(false)
    end

    it "returns false if payload version is older" do
      expect(subject.should_grow?(
               old_edition: edition,
               attrs: new_attrs.merge(publishing_api_payload_version: "3"),
             )).to eq(false)
    end

    it "returns true if there is no old edition" do
      expect(subject.should_grow?(old_edition: nil, attrs: new_attrs)).to eq(true)
    end

    it "returns false if the attributes have not changed" do
      expect(subject.should_grow?(
               old_edition: edition,
               attrs: {
                 document_text: edition.document_text,
                 publishing_api_payload_version: "5",
               },
             )).to eq(false)
    end

    context "when attributes we ignore have changed" do
      let(:attributes_that_should_not_grow_dimension) do
        %i[publishing_api_payload_version public_updated_at id update_at created_at live]
      end

      it "returns false" do
        attributes_that_should_not_grow_dimension.each do |sym|
          expect(subject.should_grow?(
                   old_edition: edition,
                   attrs: {
                     sym => "5",
                     publishing_api_payload_version: "5",
                   },
                 )).to eq(false), "#{sym} grows the dimension when it shouldn't"
        end
      end
    end

    context "when other attributes have changed" do
      let(:attributes_that_should_grow_dimension) do
        %i[
          base_path
          document_text
          document_type
          primary_organisation_id
          primary_organisation_title
          primary_organisation_withdrawn
          organisation_ids
          schema_name
          title
          phase
          publishing_app
          rendering_app
          analytics_identifier
          withdrawn
          historical
        ]
      end

      it "returns true" do
        attributes_that_should_grow_dimension.each do |sym|
          new_value = {
            organisation_ids: %w[new_value],
          }.fetch(sym, "new value")
          expect(subject.should_grow?(
                   old_edition: edition,
                   attrs: {
                     sym => new_value,
                     publishing_api_payload_version: "5",
                   },
                 )).to eq(true), "#{sym} should grow the dimension"
        end
      end
    end
  end
end
