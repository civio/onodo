class DatasetsController < ApplicationController

  before_action :set_dataset, except: [:new, :create]
  before_action :require_visualization_published!, only: :show

  # GET /datasets/:id
  def show
    filename = @dataset.visualization.name

    respond_to do |format|
      format.xlsx do
        exporter = XlsxDatasetExporter.new(@dataset)
        send_data exporter.export.to_stream.read, type: "application/xlsx", filename: "#{filename}.xlsx"
      end
    end
  end

  private

  def set_dataset
    @dataset = Dataset.find(params[:id])
  end

  def authorized
    (@dataset.visualization.author == current_user) || (@dataset.visualization.author == demo_user)
  end

  def require_visualization_published!
    redirect_to root_path unless (@dataset.visualization.published || authorized)
  end
end
