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

  # PATCH /nodes/:id/
  def update
    @node = Node.find(params[:id])
    @node.update_attributes( node_params )
    # TODO!!! Redirect to visualization that contain the node
    redirect_to edit_node_path( @node )
  end

  private

    def node_params
      params.require(:node).permit(:name, :description)
    end
end