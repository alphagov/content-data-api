require "rails_helper"

RSpec.describe Importers::TodosForTaxonomyProject do
  subject { described_class.new("foo bar", csv_parser) }
  let(:csv_parser) { double(:remote_csv_parser_service) }
  let(:content_item) { create(:content_item) }

  before do
    allow(csv_parser)
      .to receive(:each_row)
      .and_yield("content_id" => content_item.content_id)
  end

  describe "#run" do
    it "creates a taxonomy project" do
      expect { subject.run }.to change(TaxonomyProject, :count).from(0).to(1)
      expect(TaxonomyProject.first.name).to eql "foo bar"
    end

    it "creates the taxonomy todos" do
      expect { subject.run }.to change(TaxonomyTodo, :count).from(0).to(1)
    end

    it "links content items to the taxonomy project" do
      expect { subject.run }
        .to change { TaxonomyProject.first&.content_items&.count }
        .from(nil)
        .to(1)
    end
  end
end
