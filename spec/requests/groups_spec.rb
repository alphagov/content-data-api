require 'rails_helper'

RSpec.describe "API::Groups", type: :request do
  describe "GET /groups/{id}" do
    it "returns JSON with the group " do
      group = create :group, name: "a-name", slug: "the-slug"
      get group_path(group), format: :json

      json = JSON.parse(response.body).deep_symbolize_keys
      expect(json).to include(
        name: "a-name",
        slug: "the-slug"
      )
    end
  end

  describe "POST /groups" do
    context "with valid params" do
      let(:valid_params) { { group: { name: "a-name", slug: "the-slug", group_type: "the-group-type" } } }

      it "creates the group" do
        expect {
          post groups_path params: valid_params, format: :json
        }.to change(Group, :count).by(1)
      end

      it "returns status `:created` status code" do
        post groups_path params: valid_params, format: :json

        expect(response).to have_http_status(201)
      end

      it "returns a JSON with the group details" do
        post groups_path params: valid_params, format: :json

        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json).to include(
          name: "a-name",
          slug: "the-slug",
          group_type: "the-group-type"
        )
      end

      context "when a list a content IDs is provided" do
        it "add the Content Items to the group" do
          valid_params[:group][:content_item_ids] = %w(content_id_1 content_id_2)

          post groups_path params: valid_params, format: :json
          expect(Group.first.content_item_ids).to eq(%w(content_id_1 content_id_2))
        end
      end

      context "when a parent_group is provided" do
        it "creates an association with the parent" do
          parent = create(:group, slug: "parent-slug")
          valid_params[:group].merge!(parent_group_slug: "parent-slug", slug: "child-slug")

          post groups_path params: valid_params, format: :json

          child = Group.find_by(slug: "child-slug")
          expect(child.parent).to eq(parent)
        end
      end
    end

    context "with invalid params" do
      let(:invalid_params) { { group: { name: "a-name" } } }

      it "returns a `:unprocessable_entity` status code" do
        post groups_path params: invalid_params, format: :json

        expect(response).to have_http_status(422)
      end

      it "returns JSON including the errror details" do
        post groups_path params: invalid_params, format: :json

        json = JSON.parse(response.body).deep_symbolize_keys
        expect(json).to include(group_type: ["can't be blank"])
      end
    end
  end
end
