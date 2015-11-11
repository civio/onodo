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

  def publish
    @visualization = Visualization.find(params[:id])

    if @visualization.update_attributes(:published => true)
      redirect_to visualization_path( @visualization )
    else
      redirect_to edit_visualization_path( @visualization )
    end
  end

  def unpublish
    @visualization = Visualization.find(params[:id])

    if @visualization.update_attributes(:published => false)
      redirect_to visualization_path( @visualization )
    else
      redirect_to edit_visualization_path( @visualization )
    end
  end
end
