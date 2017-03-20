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
        group = create :group
        get :show, params: { id: group.to_param }, format: :json

        expect(response.status).to eq(401)
      end
    end
  end

  describe "GET #show" do
    it "assigns the requested group as @group" do
      group = create :group
      get :show, format: :json, params: { id: group.to_param, api_token: 'a-token' }

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

      it "redirects to the created group" do
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
end
