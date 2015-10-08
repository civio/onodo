class ApiController < ApplicationController
  
  respond_to :json
  
  def nodes
    respond_with Node.all
  end

  def node
    respond_with Node.find(params[:id])
  end

  def node_create
    respond_with Node.create(params[:node])
  end

  def node_update
    respond_with Node.update(params[:id], params[:node])
  end

  def node_destroy
    respond_with Node.destroy(params[:id])
  end

end
