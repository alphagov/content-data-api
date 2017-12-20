module Performance
  RSpec.describe Metrics::PagesWithWordFiles do
    subject { Metrics::PagesWithWordFiles }
    let!(:content_items) {
      [
        create(:content_item, number_of_word_files: 2),
        create(:content_item, number_of_word_files: 0),
        create(:content_item, number_of_word_files: 0),
        create(:content_item, number_of_word_files: 0)
      ]
    }

    it "returns the number of items with word files in the collection" do
      result = subject.new(Content::Item.all).run

      expect(result[:pages_with_word_files][:value]).to eq(1)
    end

    it "returns zero percent if there are no content items with word files" do
      result = subject.new(Content::Item.where("number_of_word_files = ?", 0)).run

      expect(result[:pages_with_word_files][:percentage]).to eq(0)
    end

    it "returns the number of items with word files as a percentage of the collection" do
      result = subject.new(Content::Item.all).run

      expect(result[:pages_with_word_files][:percentage]).to eq(25)
    end
  end
end
