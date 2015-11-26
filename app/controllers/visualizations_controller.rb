require 'charlock_holmes'
require 'csv'

class VisualizationsController < ApplicationController

  # GET /visualizations/:id
  def show
    @visualization = Visualization.find(params[:id])
    @nodes = Node.where(dataset_id: params[:id])
    @relations = Relation.where(dataset_id: params[:id])
    @related_items = Visualization.all
  end

  # GET /visualizations/new
  def new
    if current_user.nil?
      redirect_to new_user_session_path()
    end
  end

  # POST /visualizations
  def create
    visualization_params              = {}
    visualization_params[:name]       = params[:visualization][:name]
    visualization_params[:author_id]  = current_user.id
    @visualization  = Visualization.new( visualization_params )
    dataset         = Dataset.new
    @visualization.dataset = dataset

    unless params[:visualization][:nodes].nil?
      import_nodes(params[:visualization][:nodes], dataset)
    end

    if @visualization.save
      redirect_to visualization_path( @visualization ), :notice => "Your visualization was created!"
    else
      render "new"
    end
  end

  # GET /visualizations/:id/edit
  def edit
    if current_user.nil?
      redirect_to new_user_session_path()
    else
      @visualization = Visualization.find(params[:id])
    end
  end

  # GET /visualizations/:id/edit/info
  def editinfo
    if current_user.nil?
      redirect_to new_user_session_path()
    else
      @visualization = Visualization.find(params[:id])
    end
  end

  # PATCH /visualizations/:id/
  def update
    @visualization = Visualization.find(params[:id])
    @visualization.update_attributes( edit_info_params )
    redirect_to visualization_path( @visualization )
  end

  # DELETE /visualizations/:id/
  def destroy
    @visualization = Visualization.find(params[:id])
    @visualization.destroy
    redirect_to user_path( current_user ), :flash => { :success => "Visualization destroyed" }
  end

  # POST /visualizations/:id/publish
  def publish
    @visualization = Visualization.find(params[:id])

    if @visualization.update_attributes(:published => true)
      redirect_to visualization_path( @visualization )
    else
      redirect_to edit_visualization_path( @visualization )
    end
  end
  
  # POST /visualizations/:id/unpublish
  def unpublish
    @visualization = Visualization.find(params[:id])

    if @visualization.update_attributes(:published => false)
      redirect_to visualization_path( @visualization )
    else
      redirect_to edit_visualization_path( @visualization )
    end
  end

  private

    # TODO: aqui deberíamos validar los parámetros que queremos recibir

    def create_params
      params.require(:visualization).permit(:name, :nodes, :relations)
    end

    def edit_info_params
      params.require(:visualization).permit(:name, :description)
    end

    def import_nodes( file, dataset )
      puts file.to_s
      puts dataset.to_s
      # We can't rely on the file encoding being correct, so find out which one we got...
      content = File.read(file.path)
      detection = CharlockHolmes::EncodingDetector.detect(content)
      utf8_encoded_content = CharlockHolmes::Converter.convert content, detection[:encoding], 'UTF-8'
     
      CSV.parse(utf8_encoded_content, headers: true) do |row|
        next if row.size == 0  # Skip empty lines

        Node.new( name: row['Name'],
                  description: row['Url'], 
                  node_type: row['Family'],
                  custom_field: row['Appareances'],
                  dataset: dataset).save
      end
    end
end
