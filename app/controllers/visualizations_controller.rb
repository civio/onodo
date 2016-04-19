require 'charlock_holmes'
require 'csv'

class VisualizationsController < ApplicationController

  # GET /visualizations/:id
  def show
    @visualization  = Visualization.find(params[:id])
    @nodes          = Node.where(dataset_id: params[:id]).order(:name)
    @relations      = Relation.where(dataset_id: params[:id])
                        .includes(:source,:target)
                        .order("nodes.name")
    @related_items  = Visualization.all
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

    unless params[:visualization][:relations].nil?
      import_relations(params[:visualization][:relations], dataset)
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
      # We can't rely on the file encoding being correct, so find out which one we got...
      content = File.read(file.path)
      detection = CharlockHolmes::EncodingDetector.detect(content)
      utf8_encoded_content = CharlockHolmes::Converter.convert content, detection[:encoding], 'UTF-8'
     
      CSV.parse(utf8_encoded_content, headers: true) do |row|
        next if row.size == 0  # Skip empty lines
    
        # TODO!!! we suposse a format ID,Name,Family,Appareances,Actor,Url
        # if row['Actor']
        #   if row['Url']
        #     description = row['Actor'] + ' ' + row['Url']
        #   else
        #     description = row['Actor']
        #   end
        # elsif row['Url']
        #   description = row['Url']
        # end
        
        Node.new( name:         row['name'],
                  description:  row['description'] ? row['description'] : '',
                  node_type:    row['type'],
                  custom_field: row['custom_field'] ? row['custom_field'] : '',
                  visible:      row['visible'] ? row['visible'] : true,
                  dataset:      dataset).save!
      end
    end

    def import_relations( file, dataset )
      # We can't rely on the file encoding being correct, so find out which one we got...
      content = File.read(file.path)
      detection = CharlockHolmes::EncodingDetector.detect(content)
      utf8_encoded_content = CharlockHolmes::Converter.convert content, detection[:encoding], 'UTF-8'
     
      # Get id base
      id_base = dataset.nodes.nil? || dataset.nodes.first.nil? ? 1 : dataset.nodes.first.id.to_i
      id_base -= 1
      

      CSV.parse(utf8_encoded_content, headers: true) do |row|
        next if row.size == 0  # Skip empty lines

        # TODO!!! we suposse a format source,source_name,target,target_name,type
        
        Relation.new( source:         dataset.nodes.find( id_base+row['source'].to_i ),
                      target:         dataset.nodes.find( id_base+row['target'].to_i ), 
                      relation_type:  row['type'],
                      dataset:        dataset ).save!
      end
    end
end
