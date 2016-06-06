class Api::VisualizationsController < ApiController

  before_action :set_visualization_and_dataset
  before_action :require_visualization_ownership!, except: [:show]

  def show
  end

  def update
    custom_fields = params[:visualization][:custom_fields] || []
    @dataset.custom_fields = custom_fields.map{ |cf| cf.downcase.gsub(' ', '_') }
    @dataset.save
    params[:visualization].except!(:custom_fields)
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