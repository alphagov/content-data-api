RSpec.describe ContentItemsDecorator, type: :decorator do
  let(:organisation) { build(:organisation, title: "Organisation title") }
  let(:taxon) { build(:taxon, title: "taxon a") }

  context "without filter params" do
    it "renders the default page title" do
      content_items = [build(:content_item)]
      subject = ContentItemsDecorator.new(content_items)

      expect(subject.header).to eq("GOV.UK")
    end
  end

  context "with organisation filter" do
    it "renders the organisation title as page title" do
      subject = ContentItemsDecorator.new([])

      expect(subject.header(organisation: organisation)).to eq("Organisation title")
    end
  end

  context "with taxon filter" do
    it "renders the taxon title as page title" do
      content_items = [build(:content_item, taxons: [taxon])]
      subject = ContentItemsDecorator.new(content_items)

      expect(subject.header(taxon: taxon)).to eq("taxon a")
    end
  end

  context "with both organisation and taxon filters" do
    it "renders the organisation and taxon titles seperated by a '+'" do
      content_items = [build(:content_item, organisations: [organisation], taxons: [taxon])]
      subject = ContentItemsDecorator.new(content_items)

      expect(subject.header(organisation: organisation, taxon: taxon)).to eq("Organisation title + taxon a")
    end
  end
end
