require "rails_helper"

RSpec.describe Importers::SingleContentItem do
  let(:content_id) { "id-123" }

  let!(:org1) { FactoryGirl.create(:organisation, content_id: "org-1") }
  let!(:org2) { FactoryGirl.create(:organisation, content_id: "org-2") }

  let!(:taxon1) { FactoryGirl.create(:taxonomy, content_id: "taxon-1") }
  let!(:taxon2) { FactoryGirl.create(:taxonomy, content_id: "taxon-2") }

  let(:content_item) { FactoryGirl.build(:content_item, content_id: content_id, title: "title") }

  def links
    [
      FactoryGirl.build(:link, source_content_id: content_id, link_type: "organisations", target_content_id: "org-1"),
      FactoryGirl.build(:link, source_content_id: content_id, link_type: "organisations", target_content_id: "org-2"),
      FactoryGirl.build(:link, source_content_id: content_id, link_type: "taxons", target_content_id: "taxon-1"),
      FactoryGirl.build(:link, source_content_id: content_id, link_type: "taxons", target_content_id: "taxon-2"),
    ]
  end

  before do
    allow(subject.content_items_service)
      .to receive(:fetch).with(content_id)
      .and_return(content_item)

    allow(subject.content_items_service)
      .to receive(:links).with(content_id) { links }

    allow(subject.metric_builder)
      .to receive(:run_all)
      .and_return(number_of_pdfs: 10)
  end

  it "imports a content item" do
    expect { subject.run(content_id) }
      .to change(ContentItem, :count).by(1)

    content_item = ContentItem.last

    expect(content_item.title).to eq("title")
    expect(content_item.organisations).to eq [org1, org2]
    expect(content_item.taxonomies).to eq [taxon1, taxon2]
    expect(content_item.number_of_pdfs).to eq(10)
  end

  it "imports links" do
    expect { subject.run(content_id) }
      .to change(Link, :count).by(4)

    content_item = ContentItem.last
    content_item_links = Link.where(source_content_id: content_item.content_id)

    expect(
      content_item_links.where(
        link_type: "organisations"
      ).pluck(:target_content_id)
    ).to contain_exactly(*%w(org-1 org-2))

    expect(
      content_item_links.where(
        link_type: "taxons"
      ).pluck(:target_content_id)
    ).to contain_exactly(*%w(taxon-1 taxon-2))
  end

  context "when the content item already exists" do
    before do
      FactoryGirl.create(
        :content_item,
        content_id: content_id,
        title: "old title",
        organisations: [org1],
        taxonomies: [taxon2],
        number_of_pdfs: 5,
      )
    end

    it "updates the content item" do
      expect { subject.run(content_id) }
        .to  change { ContentItem.last.title }.from("old title").to("title")
        .and change { ContentItem.last.organisations.to_a }.from([org1]).to([org1, org2])
        .and change { ContentItem.last.taxonomies.to_a }.from([taxon2]).to([taxon1, taxon2])
        .and change { ContentItem.last.number_of_pdfs }.from(5).to(10)
    end
  end

  context "when the links already exists, and the Publishing API is unchanged" do
    before do
      subject.run(content_id)
    end

    it "doesn't create any additional links" do
      expect { subject.run(content_id) }
      .not_to change(Link, :count)
    end

    context "when all the links have been removed" do
      before do
        allow(subject.content_items_service)
          .to receive(:links).with(content_id) { [] }
      end

      it "deletes non-existing links" do
        expect { subject.run(content_id) }
          .to change(Link, :count).by(-4)
      end
    end
  end
end
