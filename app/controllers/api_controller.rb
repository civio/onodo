class ApiController < ApplicationController

  # Get all Nodes (for a visualization)
  # GET /api/:dataset_id/nodes
  def nodes
    render json: Node.where(dataset_id: params[:dataset_id])
  end

  # Get a Node
  # GET /api/:dataset_id/nodes/:id
  def node
    render json: Node.find(params[:id])
  end

  # Create a new Node
  # POST /api/:dataset_id/nodes
  def node_create
    render json: Node.create(node_params)
  end

  # Update a Node attribute
  # PUT /api/:dataset_id/nodes/:id
  def node_update
    render json: Node.update(params[:id], node_params)
  end

  # Delete a Node
  # DELETE /api/:dataset_id/nodes/:id
  def node_destroy
    render json: Node.destroy(params[:id])
  end

  # Get uniques & non-blank Nodes Types 
  # GET /api/nodes-types
  def node_types
    render json: Node.select(:node_type).map(&:node_type).reject(&:blank?).uniq
  end

  ###

  # Get all Relations (for a visualization)
  # GET /api/:dataset_id/relations
  def relations
    render json: Relation.where(dataset_id: params[:dataset_id])
  end

  # Get a Relation
  # GET /api/:dataset_id/relations/:id
  def relation
    render json: Relation.find(params[:id])
  end

  # Create a new Relation
  # POST /api/:dataset_id/relations
  def relation_create
    render json: Relation.create(relation_params)
  end

  # Update a Relation attribute
  # PUT /api/:dataset_id/relations/:id
  def relation_update
    render json: Relation.update(params[:id], relation_params)
  end

  # Delete a Relation
  # DELETE /api/:dataset_id/relations/:id
  def relation_destroy
    render json: Relation.destroy(params[:id])
  end

  private

    def node_params
      params.require(:id).permit(:dataset_id, :name, :description, :created_at, :updated_at, :visible, :node_type) if params[:node]
    end

    def relation_params
      params.require(:id, :source_id, :target_id).permit(:dataset_id, :created_at, :updated_at, :relation_type) if params[:relation]
    end

end
