class NodesController < ApplicationController

  # GET /nodes
  def index
    @nodes = Node.all
    @relations = Relation.all
  end

  # GET /nodes/:id/edit
  def edit
    # TODO!!! Check if current_user is the owner of this node
    if current_user.nil?
      #redirect_to new_user_session_path()
    else
      @node = Node.find(params[:id])
    end
  end

  # GET /nodes/:id/edit/description
  def edit_description
    # TODO!!! Check if current_user is the owner of this node
    if current_user.nil?
      #redirect_to new_user_session_path()
    else
      @node = Node.find(params[:id])
    end

    render layout: false
  end

  # GET /nodes/:id/edit/image
  def edit_image
    # TODO!!! Check if current_user is the owner of this node
    if current_user.nil?
      #redirect_to new_user_session_path()
    else
      @node = Node.find(params[:id])
    end

    render layout: false
  end

  # PATCH /nodes/:id/
  def update
    @node = Node.find(params[:id])
    @node.update_attributes( node_params )
    # TODO!!! Redirect to visualization that contain the node
    #redirect_to edit_node_path( @node )
    render nothing: true, head: :ok, content_type: 'text/html'
  end

  private

    def node_params
      params.require(:node).permit(:name, :description, :image, :image_cache, :remote_image_url)
    end
end
