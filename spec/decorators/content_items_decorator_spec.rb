RSpec.describe ContentItemsDecorator, type: :decorator do
  let(:organisation) { build(:organisation, title: "Organisation title") }
  let(:taxonomy) { build(:taxonomy, title: "taxonomy a") }

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

  context "with taxonomy filter" do
    it "renders the taxonomy title as page title" do
      content_items = [build(:content_item, taxonomies: [taxonomy])]
      subject = ContentItemsDecorator.new(content_items)

      expect(subject.header(taxonomy: taxonomy)).to eq("taxonomy a")
    end
  end

  context "with both organisation and taxonomy filters" do
    it "renders the organisation and taxonomy titles seperated by a '+'" do
      content_items = [build(:content_item, organisations: [organisation], taxonomies: [taxonomy])]
      subject = ContentItemsDecorator.new(content_items)

      expect(subject.header(organisation: organisation, taxonomy: taxonomy)).to eq("Organisation title + taxonomy a")
    end
  end
end
