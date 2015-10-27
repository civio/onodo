class ApiController < ApplicationController

  #respond_to :json

  # Get all Nodes
  def nodes
    render json: Node.all
  end

  # Get a Node
  def node
    render json: Node.find(params[:id])
  end

  # Create a new Node
  def node_create
    render json: Node.create(node_params)
  end

  # Update a Node attribute
  def node_update
    render json: Node.update(params[:id], node_params)
  end

  # Delete a Node
  def node_destroy
    render json: Node.destroy(params[:id])
  end

  # Get uniques & non-blank Nodes Types 
  def node_types
    render json: Node.select(:node_type).map(&:node_type).reject(&:blank?).uniq
  end

  private

    def node_params
      params.require(:node).permit(:id, :name, :description, :created_at, :updated_at, :visible, :node_type) if params[:node]
    end

end
