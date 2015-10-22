class ApiController < ApplicationController
  
  respond_to :json
  
  # Get all Nodes
  def nodes
    respond_with Node.all
  end

  # Get a Node
  def node
    respond_with Node.find(params[:id])
  end

  # Create a new Node
  def node_create
    respond_with Node.create(node_params)
  end

  # Update a Node attribute
  def node_update
    respond_with Node.update(params[:id], node_params)
  end

  # Delete a Node
  def node_destroy
    respond_with Node.destroy(params[:id])
  end

  # Get uniques & non-blank Nodes Types 
  def node_types
    respond_with Node.select(:node_type).map(&:node_type).reject(&:blank?).uniq
  end

  private

    def node_params
      params.require(:node).permit(:id, :name, :description, :created_at, :updated_at, :visible, :node_type) if params[:node]
    end

end
