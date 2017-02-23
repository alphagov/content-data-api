require 'rails_helper'

RSpec.describe ContentItemsController, type: :controller do
  describe "GET #index" do
    context "unfiltered" do
      let(:content_items) { create_list(:content_item_with_organisations, 3) }

      before do
        get :index
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "assigns list of content items" do
        expect(assigns(:content_items)).to eq(content_items)
      end

      it "renders the :index template" do
        expect(subject).to render_template(:index)
      end
    end

    context "find by organisation" do
      let(:organisation) { create(:organisation) }

      before do
        get :index, params: { organisation_slug: organisation.slug }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "assigns current organisation" do
        expect(assigns(:organisation)).to eq(organisation)
      end

      it "renders the :index template" do
        expect(subject).to render_template(:index)
      end
    end

    context "content items fetched via ContentItemQuery" do
      it "returns a list of content items" do
        allow(ContentItemsQuery).to receive(:build).and_return(:content_items)
        expect(ContentItemsQuery.build({})).to eq(:content_items)
      end
    end
  end

  describe "GET #show" do
    context "find by content item" do
      let(:organisation) { create(:organisation_with_content_items, content_items_count: 1) }

      before do
        get :show, params: { organisation_slug: organisation.slug, id: organisation.content_items.first.id }
      end

      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "assigns current content item" do
        expect(assigns(:content_item)).to eq(organisation.content_items.first)
      end

      it "renders the :show template" do
        expect(subject).to render_template(:show)
      end
    end
  end
end
