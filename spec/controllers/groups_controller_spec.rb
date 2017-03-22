require 'rails_helper'

RSpec.describe GroupsController, type: :controller do
  before do
    @old_content_performance_manager_token = ENV['CONTENT-PERFORMANCE-MANAGER-TOKEN']
    ENV['CONTENT-PERFORMANCE-MANAGER-TOKEN'] = 'a-token'
  end

  after { ENV['CONTENT-PERFORMANCE-MANAGER-TOKEN'] = @old_content_performance_manager_token }

  describe "Authorisation" do
    context "When no API token is provided" do
      it "returns 401 status code" do
        create :group, slug: "the-slug"
        get :show, params: { slug: "the-slug" }, format: :json

        expect(response.status).to eq(401)
      end
    end
  end

  describe "GET #index" do
    it "assigns all groups as @groups" do
      group = create(:group)
      get :index, params: { api_token: 'a-token' }, format: :json

      expect(assigns(:groups)).to eq([group])
    end

    it "filters by group type" do
      create(:group)
      group2 = create(:group, group_type: 'the-type')
      get :index, params: { group_type: 'the-type', api_token: 'a-token' }, format: :json

      expect(assigns(:groups)).to eq([group2])
    end
  end

  describe "GET #show" do
    it "assigns the requested group as @group" do
      group = create :group, slug: "the-slug"
      get :show, format: :json, params: { slug: "the-slug", api_token: 'a-token' }

      expect(assigns(:group)).to eq(group)
    end
  end

  describe "POST #create" do
    let(:valid_attributes) { attributes_for(:group) }
    let(:invalid_attributes) { { name: 'a-name', group_type: 'a-type' } }

    context "with valid params" do
      it "creates a new Group" do
        expect {
          post :create, format: :json, params: { group: valid_attributes, api_token: 'a-token' }
        }.to change(Group, :count).by(1)
      end

      it "assigns a newly created group as @group" do
        post :create, format: :json, params: { group: valid_attributes, api_token: 'a-token' }
        expect(assigns(:group)).to be_a(Group)
        expect(assigns(:group)).to be_persisted
      end

      it "assigns :created (201) status code" do
        post :create, format: :json, params: { group: valid_attributes, api_token: 'a-token' }
        expect(response.status).to eq(201)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved group as @group" do
        post :create, format: :json, params: { group: invalid_attributes, api_token: 'a-token' }

        expect(assigns(:group)).to be_a_new(Group)
        expect(assigns(:group).errors).to_not be_empty
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:group) { create :group, slug: "the-slug" }

    it "destroys the requested group" do
      expect {
        delete :destroy, params: { slug: "the-slug", api_token: 'a-token' }, format: :json
      }.to change(Group, :count).by(-1)
    end

    it "returns head: no_content" do
      delete :destroy, params: { slug: "the-slug", api_token: 'a-token' }, format: :json

      expect(response).to have_http_status(200)
    end
  end
end
