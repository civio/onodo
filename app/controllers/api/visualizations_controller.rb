class Api::VisualizationsController < ApiController

  before_action :set_visualization_and_dataset
  before_action :require_visualization_ownership!, except: [:show]

  def show
  end

  def update
    node_custom_fields = params[:visualization][:node_custom_fields] || []
    @dataset.node_custom_fields = node_custom_fields.map{ |cf| { "name" => cf["name"].downcase.gsub(' ', '_'), "type" => ["string", "number", "boolean"].any?{ |t| t == cf["type"].downcase } ? cf["type"].downcase : "string" } }
    @dataset.save
    params[:visualization].except!(:node_custom_fields)
    @visualization.update(visualization_params)
    render :show
  end

  private

  def set_visualization_and_dataset
    @visualization = Visualization.find(params[:id])
    @dataset = @visualization.dataset
  end

  def require_visualization_ownership!
    render :show and return if @visualization.author != current_user
  end

  def visualization_params
    params.require(:visualization).permit(:name, :description, :published, :author_id, :parameters)
  end

end