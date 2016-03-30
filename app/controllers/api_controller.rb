class ApiController < ApplicationController

  # Get all Nodes (for a visualization)
  # GET /api/:dataset_id/nodes
  def nodes
    render json: Node.where(dataset_id: params[:dataset_id])
  end

  # Get a Node
  # GET /api/nodes/:id
  def node
    render json: Node.find(params[:id])
  end

  # Create a new Node
  # POST /api/nodes
  def node_create
    #puts node_params
    node = Node.new(node_params)
    node.save(:validate => false)
    render json: node
  end

  # Update a Node attribute
  # PUT /api/nodes/:id
  def node_update
    Node.update(params[:id], node_params)
    render json: {}
    #TODO! Add error validation
  end

  # Delete a Node
  # DELETE /api/nodes/:id
  def node_destroy
    Node.destroy(params[:id])
    render json: {}
    #TODO! Add error validation
  end

  # Get uniques & non-blank Nodes Types 
  # GET /api/nodes/types
  def node_types
    render json: Node.select(:node_type).map(&:node_type).reject(&:blank?).uniq
  end

  ###

  # Get all Relations (for a visualization)
  # GET /api/:dataset_id/relations
  def relations
    @relations = Relation.where(dataset_id: params[:dataset_id]).includes(:source,:target)
  end

  # Get a Relation
  # GET /api/relations/:id
  def relation
    render json: Relation.find(params[:id])
  end

  # Create a new Relation
  # POST /api/relations
  def relation_create
    Relation.create(relation_params)
    render json: {}
  end

  # Update a Relation attribute
  # PUT /api/relations/:id
  def relation_update
    Relation.update(params[:id], relation_params)
    render json: {}
  end

  # Delete a Relation
  # DELETE /api/relations/:id
  def relation_destroy
    Relation.destroy(params[:id])
    render json: {}
  end

  private

    def node_params
      params.require(:node).permit(:name, :description, :visible, :node_type, :custom_field, :dataset_id) if params[:node]
    end

    def relation_params
      params.require(:relation).permit(:source_id, :target_id, :relation_type) if params[:relation]
    end

end
