require "rails_helper"

RSpec.describe Importers::TodosForTaxonomyProject do
  subject { described_class.new(create(:taxonomy_project), csv_parser) }
  let(:csv_parser) { double(:remote_csv_parser_service) }
  let(:content_item) { create(:content_item) }

  before do
    allow(csv_parser)
      .to receive(:each_row)
      .and_yield("content_id" => content_item.content_id)
  end

  describe "#run" do
    it "creates the term_generation todos" do
      expect { subject.run }.to change(TaxonomyTodo, :count).from(0).to(1)
    end

    it "links content items to the term_generation project" do
      expect { subject.run }
        .to change { TaxonomyProject.first&.taxonomy_todos&.count }
        .from(nil)
        .to(1)
    end

    it "keeps track of errors" do
      content_item.destroy
      expect { subject.run }
        .to change { subject.errors.size }
        .from(0)
        .to(1)
    end
  end
end
