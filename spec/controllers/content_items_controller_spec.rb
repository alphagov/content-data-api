require 'rails_helper'

RSpec.describe ContentItemsController, type: :controller do
  describe "GET #index" do
    it "returns http success" do
      get :index

      expect(response).to have_http_status(:success)
    end

    it "assigns list of content items" do
      expect(ContentItemsQuery).to receive(:build).and_return(double('collection', decorate: :the_results))
      get :index

      expect(assigns(:content_items)).to eq(:the_results)
    end

    it "build the query with the expected params" do
      expected_params = { sort: 'title', order: 'asc', page: '1', taxonomy: nil, organisation: nil, query: 'a title' }
      expect(ContentItemsQuery).to receive(:build).with(expected_params).and_return(double('collection', decorate: :the_results))

      get :index, params: expected_params
    end

    it "assigns the organisation provided the slug" do
      create(:organisation, slug: 'the-slug')

      get :index, params: { organisation_slug: 'the-slug' }
      expect(assigns(:organisation).slug).to eq('the-slug')
    end

    it "assigns the taxonomy provided by the taxonomy title" do
      create(:taxonomy, title: 'education')

      get :index, params: { taxonomy_title: 'education' }
      expect(assigns(:taxonomy).title).to eq('education')
    end

    it "renders the :index template" do
      get :index

      expect(subject).to render_template(:index)
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

      it "decorates the content item" do
        expect(assigns(:content_item)).to be_decorated
      end

      it "renders the :show template" do
        expect(subject).to render_template(:show)
      end
    end
  end

  describe "GET #filter" do
    it "returns http success" do
      get :filter

      expect(response).to have_http_status(:success)
    end

    it "assigns a list of organisations" do
      organisations = create_list(:organisation, 2)
      get :filter

      expect(assigns(:organisations)).to match_array(organisations)
    end

    it "assigns a list of taxonomies" do
      taxonomies = create_list(:taxonomy, 2)
      get :filter

      expect(assigns(:taxonomies)).to match_array(taxonomies)
    end

    it "renders the filter template" do
      get :filter

      expect(response).to render_template("filter")
    end
  end
end
