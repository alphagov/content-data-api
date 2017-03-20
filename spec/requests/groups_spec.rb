require 'rails_helper'

RSpec.describe "API::Groups", type: :request do
  let(:headers) { { "ACCEPT" => "application/json" } }

  before do
    @old_content_performance_manager_token = ENV['CONTENT-PERFORMANCE-MANAGER-TOKEN']
    ENV['CONTENT-PERFORMANCE-MANAGER-TOKEN'] = 'a-token'
  end

  after { ENV['CONTENT-PERFORMANCE-MANAGER-TOKEN'] = @old_content_performance_manager_token }

  describe "GET /groups/{id}" do
    let!(:group) { create :group, name: "a-name", slug: "the-slug" }

    before do
      get "/groups/#{group.id}", params: { api_token: "a-token" }, headers: headers
    end

    it "returns JSON with the group " do
      json = JSON.parse(response.body).deep_symbolize_keys

      expect(json).to include(name: "a-name", slug: "the-slug")
    end
  end

  describe "POST /groups" do
    context "with valid params" do
      let(:params) { { group: attributes_for(:group), api_token: "a-token" } }

      it "creates the group" do
        expect {
          post "/groups", params: params, headers: headers
        }.to change(Group, :count).by(1)
      end

      it "returns status code :created" do
        post "/groups", params: params, headers: headers

        expect(response).to have_http_status(201)
      end

      it "returns a JSON with the group details" do
        params[:group][:name] = "a-name"
        params[:group][:slug] = "the-slug"
        post "/groups", params: params, headers: headers

        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json).to include(
          name: "a-name",
          slug: "the-slug"
        )
      end

      context "when a list of content IDs is provided" do
        it "adds the Content IDs to the group" do
          params[:group][:content_item_ids] = %w(content_id_1 content_id_2)

          post "/groups", params: params, headers: headers
          expect(Group.first.content_item_ids).to eq(%w(content_id_1 content_id_2))
        end
      end

      context "when a parent_group is provided" do
        let!(:parent) { create(:group, slug: "parent-slug") }

        it "creates an association with the parent" do
          params[:group].merge!(parent_group_slug: "parent-slug", slug: "child-slug")

          post "/groups", params: params, headers: headers

          child = Group.find_by(slug: "child-slug")
          expect(child.parent).to eq(parent)
        end
      end
    end

    context "with invalid params" do
      let(:invalid_params) { { group: { name: "a-name" }, api_token: "a-token" } }

      before do
        post "/groups", params: invalid_params, headers: headers
      end

      it "returns a `:unprocessable_entity` status code" do
        expect(response).to have_http_status(422)
      end

      it "returns JSON including the errror details" do
        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json).to include(group_type: ["can't be blank"])
      end
    end
  end
end
