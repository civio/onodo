class Api::VisualizationsController < ApiController

  def show
    @visualization = Visualization.find(params[:id])
    @dataset = @visualization.dataset
  end

  def update
    @visualization = Visualization.find(params[:id])
    @dataset = @visualization.dataset
    custom_fields = params[:visualization][:custom_fields] || []
    @dataset.custom_fields = custom_fields.map{ |cf| cf.downcase.gsub(' ', '_') }
    @dataset.save
    params[:visualization].except!(:custom_fields)
    @visualization.update(visualization_params)
    render :show
  end

  private

  def visualization_params
    params.require(:visualization).permit(:name, :description, :published, :author_id, :parameters)
  end

end