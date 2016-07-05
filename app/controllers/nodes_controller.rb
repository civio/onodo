class NodesController < ApplicationController

  before_action :authenticate_user!
  before_action :set_node
  before_action :require_node_ownership!

  # GET /nodes/:id/edit
  def edit
    # TODO!!! Check if current_user is the owner of this node
    if current_user.nil?
      #redirect_to new_user_session_path()
    end
  end

  # GET /nodes/:id/edit/description
  def edit_description
    # TODO!!! Check if current_user is the owner of this node
    if current_user.nil?
      #redirect_to new_user_session_path()
    end
    render layout: false
  end

  # GET /nodes/:id/edit/image
  def edit_image
    # TODO!!! Check if current_user is the owner of this node
    if current_user.nil?
      #redirect_to new_user_session_path()
    end
    render layout: false
  end

  # PATCH /nodes/:id/
  def update
    @node.update_attributes( node_params )
    location = edit_visualization_path(@node.visualization)
    render json: { location: location } and return if xhr_request?
    redirect_to location
  end

  # PATCH /nodes/:id/image
  def update_image
    @node.update_attributes( node_params )
    redirect_to edit_node_path(@node)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_node
    @node = Node.find(params[:id])
  end

  def require_node_ownership!
    redirect_to visualization_path(@node.visualization) unless authorized
  end

  def authorized
    (@node.visualization.author == current_user) || (@node.visualization.author == demo_user)
  end

  def node_params
    params.require(:node).permit(:name, :description, :image, :image_cache, :remote_image_url, :remove_image, custom_fields: params[:node][:custom_fields].try(:keys))
  end
end
