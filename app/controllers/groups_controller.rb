class GroupsController < ApplicationController
  protect_from_forgery unless: -> { request.format.json? }

  before_action :set_parent_group, only: :create

  def show
    @group = Group.find(params[:id])
  end

  def create
    @group = Group.new(group_params)

    if @group.save
      render :show, status: :created
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

private

  def set_parent_group
    parent_group_slug = params[:group][:parent_group_slug]
    if parent_group_slug
      parent = Group.find_by(slug: parent_group_slug)
      params[:group][:parent_group_id] = parent.id
    end
  end

  def group_params
    params.require(:group).permit(:slug, :name, :parent_group_id, :group_type, content_item_ids: [])
  end
end
