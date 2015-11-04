class ApiController < ApplicationController

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

  ###

  # Get all Relations
  def relations
    render json: Relation.all
  end

  # Get a Relation
  def relation
    render json: Relation.find(params[:id])
  end

  # Create a new Relation
  def relation_create
    render json: Relation.create(relation_params)
  end

  # Update a Relation attribute
  def relation_update
    render json: Relation.update(params[:id], relation_params)
  end

  # Delete a Relation
  def relation_destroy
    render json: Relation.destroy(params[:id])
  end

  private

    def node_params
      params.require(:id, :node).permit(:name, :description, :created_at, :updated_at, :visible, :node_type) if params[:node]
    end

    def relation_params
      params.require(:id, :source_id, :source_id).permit(:created_at, :updated_at, :relation_type) if params[:relation]
    end

end
