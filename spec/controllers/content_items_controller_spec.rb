require 'rails_helper'

RSpec.describe ContentItemsController, type: :controller do
  describe "GET #index" do

    before { allow(ContentItemsQuery).to receive(:build).and_return(:the_content_items) }

    it "returns http success" do
      get :index

      expect(response).to have_http_status(:success)
    end

    it "assigns list of content items" do
      get :index

      expect(assigns(:content_items)).to eq(:the_content_items)
    end

    it "renders the :index template" do
      get :index

      expect(subject).to render_template(:index)
    end

    describe "Query filter" do
      it "filters by organisation" do
        organisation = create(:organisation, slug: 'organisation-slug')

        get :index, params: { organisation_slug: 'organisation-slug' }

        expect(ContentItemsQuery).to have_received(:build).with(hash_including(organisation: organisation))
      end

      it "paginates the results" do
        get :index, params: { page: 10 }

        expect(ContentItemsQuery).to have_received(:build).with(hash_including(page: "10"))
      end

      it "sorts the results" do
        get :index, params: { order: 'attribute', sort: 'asc' }

        expect(ContentItemsQuery).to have_received(:build).with(hash_including(order: 'attribute', sort: 'asc'))
      end
    end

    context "when organisation slug is present" do
      let!(:organisation) { create(:organisation, slug: 'organisation-slug') }

      it "assigns current organisation" do
        get :index, params: { organisation_slug: 'organisation-slug' }

        expect(assigns(:organisation)).to eq(organisation)
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
