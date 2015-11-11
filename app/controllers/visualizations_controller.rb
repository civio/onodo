class VisualizationsController < ApplicationController

  def index
    @visualizations = Visualization.all
  end

  def show
    @visualization = Visualization.find(params[:id])
    @nodes = Node.where(dataset_id: params[:id])
    @relations = Relation.where(dataset_id: params[:id])
    @related_items = Visualization.all
  end

  def edit
    @visualization = Visualization.find(params[:id])
  end
end
