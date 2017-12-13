module Content
  RSpec.describe Importers::SingleContentItem do
    let(:content_id) { "id-123" }
    let(:locale) { "en" }
    let(:version) { "5" }

    let!(:org1) { create(:content_item, title: "org-1", content_id: "org-id-1") }
    let!(:org2) { create(:content_item, title: "org-2", content_id: "org-id-2") }

    let!(:taxon1) { create(:content_item, title: "taxon-1", content_id: "taxon-id-1") }
    let!(:taxon2) { create(:content_item, title: "taxon-2", content_id: "taxon-id-2") }

    let(:partial_content_item) { { content_id: content_id, locale: locale } }
    let(:content_item) { build(:content_item, content_id: content_id, title: "title") }

    before do
      allow(subject.metric_builder).to receive(:run_all).and_return(number_of_pdfs: 10)
      allow(subject.content_items_service).to receive(:links).with(content_id) { links }
    end

    def links
      [
        build(:link, source: content_item, link_type: "organisations", target: org1),
        build(:link, source: content_item, link_type: "organisations", target: org2),
        build(:link, source: content_item, link_type: "taxons", target: taxon1),
        build(:link, source: content_item, link_type: "taxons", target: taxon2),
      ]
    end

    context "Import a new Content Item" do
      before do
        allow(subject.content_items_service).to receive(:fetch)
          .with(content_id, locale, version)
          .and_return(content_item)
      end

      it "imports a content item" do
        expect { subject.run(content_id, locale, version) }.to change(Content::Item, :count).by(1)

        content_item = Content::Item.last

        expect(content_item.title).to eq("title")
        expect(content_item.linked_organisations).to match_array([org1, org2])
        expect(content_item.linked_taxons).to match_array([taxon1, taxon2])
        expect(content_item.number_of_pdfs).to eq(10)
      end

      it "imports links" do
        expect { subject.run(content_id, locale, version) }
          .to change(Content::Link, :count).by(4)

        content_item = Content::Item.last
        content_item_links = Content::Link.where(source_content_id: content_item.content_id)

        expect(
          content_item_links.where(
            link_type: "organisations"
          ).pluck(:target_content_id)
        ).to contain_exactly('org-id-1', 'org-id-2')

        expect(
          content_item_links.where(
            link_type: "taxons"
          ).pluck(:target_content_id)
        ).to contain_exactly('taxon-id-1', 'taxon-id-2')
      end
    end

    context "when the content item already exists" do
      let(:updated_content_item) { build(:content_item, content_id: content_id, title: "new title") }

      before do
        allow(subject.content_items_service).to receive(:fetch).with(content_id, locale, version).and_return(updated_content_item)
      end

      it "updates the content item" do
        content_item.save!

        expect { subject.run(content_id, locale, version) }
          .to change { content_item.reload.title }.from("title").to("new title")
          .and change { content_item.reload.linked_taxons.to_a }.from([]).to([taxon1, taxon2])
          .and change { content_item.reload.linked_organisations.to_a }.from([]).to([org1, org2])
          .and change { content_item.reload.number_of_pdfs }.from(0).to(10)
      end

      it "does not override `six_months_page_views` attributes" do
        content_item.update!(six_months_page_views: 1000)

        expect { subject.run(content_id, locale, version) }
          .to_not change(content_item.reload, :six_months_page_views)
      end

      it "does not override `one_month_page_views` attributes" do
        content_item.update!(one_month_page_views: 1000)

        expect { subject.run(content_id, locale, version) }
          .to_not change(content_item.reload, :one_month_page_views)
      end
    end

    context "when the links already exists, and the Publishing API is unchanged" do
      before do
        allow(subject.content_items_service).to receive(:fetch).with(content_id, locale, version).and_return(content_item)
        subject.run(content_id, locale, version)
      end

      it "doesn't create any additional links" do
        expect { subject.run(content_id, locale, version) }
          .not_to change(Content::Link, :count)
      end

      context "when all the links have been removed" do
        before do
          allow(subject.content_items_service)
            .to receive(:links).with(content_id) { [] }
        end

        it "deletes non-existing links" do
          expect { subject.run(content_id, locale, version) }
            .to change(Content::Link, :count).by(-4)
        end
      end
    end
  end
end
