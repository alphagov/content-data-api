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
    let(:content_item) { create(:content_item) }

    before do
      get :show, params: { id: content_item.id }
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "assigns current content item" do
      expect(assigns(:content_item)).to eq(content_item)
    end

    it "decorates the content item" do
      expect(assigns(:content_item)).to be_decorated
    end

    it "renders the :show template" do
      expect(subject).to render_template(:show)
    end
  end
end
