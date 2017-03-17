require "rails_helper"

RSpec.describe ContentItemsDecorator, type: :decorator do
  include Draper::ViewHelpers

  let(:organisation) { create(:organisation, title: "Organisation title", slug: "the-slug") }
  let(:taxonomy) { create(:taxonomy, title: "taxonomy a") }

  context "without filter params" do
    it "renders the default page title" do
      allow(helpers).to receive(:params).and_return({})
      content_items = [build(:content_item)]
      subject = ContentItemsDecorator.new(content_items)

      expect(subject.header).to eq("GOV.UK")
    end
  end

  context "with organisation filter" do
    it "renders the organisation title as page title" do
      allow(helpers).to receive(:params).and_return(organisation_slug: "the-slug")
      content_items = [build(:content_item, organisations: [organisation])]
      subject = ContentItemsDecorator.new(content_items)

      expect(subject.header).to eq("Organisation title")
    end
  end

  context "with taxonomy filter" do
    it "renders the taxonomy title as page title" do
      allow(helpers).to receive(:params).and_return(taxonomy: "taxonomy a")
      content_items = [build(:content_item, taxonomies: [taxonomy])]
      subject = ContentItemsDecorator.new(content_items)

      expect(subject.header).to eq("taxonomy a")
    end
  end

  context "with both organisation and taxonomy filters" do
    it "renders the organisation and taxonomy titles seperated by a '+'" do
      allow(helpers).to receive(:params).and_return(organisation_slug: "the-slug", taxonomy: "taxonomy a")
      content_items = [build(:content_item, organisations: [organisation], taxonomies: [taxonomy])]
      subject = ContentItemsDecorator.new(content_items)

      expect(subject.header).to eq("Organisation title + taxonomy a")
    end
  end
end
