class DatasetsController < ApplicationController

  # GET /datasets/:id
  def show
    dataset = Dataset.find(params[:id])
    filename = dataset.visualization.name

    respond_to do |format|
      format.xlsx do
        exporter = XlsxDatasetExporter.new(dataset)
        send_data exporter.export.to_stream.read, type: "application/xlsx", filename: "#{filename}.xlsx"
      end
    end
  end
end