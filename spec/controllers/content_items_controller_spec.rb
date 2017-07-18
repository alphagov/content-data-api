RSpec.describe ContentItemsController, type: :controller do
  include AuthenticationControllerHelpers

  before do
    login_as_stub_user
  end

  describe "GET #index" do
    it "returns http success" do
      get :index

      expect(response).to have_http_status(:success)
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
        get :show, params: { id: organisation.content_items.first.id }
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
end
