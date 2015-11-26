class DatasetsController < ApplicationController

  # GET /datasets
  def index
    @datasets = Dataset.all
  end
end