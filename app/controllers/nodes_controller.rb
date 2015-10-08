class NodesController < ApplicationController
  
  respond_to :json
  
  def index
    respond_with Node.all
  end


  respond_to :html

  def index
    @nodes = Node.all
  end

  def create
    @node = Node.new(node_params)

    if @node.save
      render json: @node
    else
      render json: @node.errors, status: :unprocessable_entity
    end
  end

  def update
    @node = Node.find(params[:id])

    if @node.update(node_params)
      render json: @node
    else
      render json: @node.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @node = Node.find(params[:id])
    @node.destroy
    head :no_content
  end

  private

    def node_params
      params.require(:node).permit(:name, :description)
    end

end
