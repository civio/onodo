class ApiController < ApplicationController
  
  respond_to :json
  
  def nodes
    respond_with Node.all
  end

  def node
    respond_with Node.find(params[:id])
  end

  def node_create
    respond_with Node.create(node_params)
  end

  def node_update
    respond_with Node.update(params[:id], node_params)
  end

  def node_destroy
    respond_with Node.destroy(params[:id])
  end

  private

    def node_params
      params.require(:node).permit(:id, :name, :description, :created_at, :updated_at, :visible) if params[:node]
    end

end
