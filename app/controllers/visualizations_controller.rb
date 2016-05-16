require 'charlock_holmes'
require 'csv'
require 'axlsx'
require 'roo'

class VisualizationsController < ApplicationController

  # GET /visualizations/:id
  def show
    @visualization  = Visualization.find(params[:id])
    @visualization_id = @visualization.id
    dataset         = Dataset.find_by(visualization_id: params[:id])
    @nodes          = Node.where(dataset_id: dataset.id)
    @relations      = Relation.where(dataset_id: dataset.id).includes(:source, :target).order("nodes.name", "targets_relations.name")
    
    respond_to do |format|
      format.html do
        # reorder nodes & relations
        @nodes          = @nodes.order(:name)
        @relations      = @relations.includes(:source,:target).order("nodes.name")
        # !!!TODO -> we get all visualization for related_items; needs improvement
        @related_items  = Visualization.all
      end
      format.xlsx do
        p = Axlsx::Package.new
        wb = p.workbook
        bold = wb.styles.add_style b: true
        @nodes = @nodes.order(:id)
        # setup nodes sheet
        wb.add_worksheet(name: "Nodes") do |sheet|
          sheet.add_row ["Name", "Type", "Description", "Visible"] + (dataset.custom_fields || []).map{ |cf| cf.capitalize.gsub('_', ' ')}, style: bold
          @nodes.each do |node|
            sheet.add_row [node.name, node.node_type, node.description, node.visible ? nil : 0] + (dataset.custom_fields || []).map{ |cf| custom_fields = (node.custom_fields || {}); custom_fields[cf] }
          end
        end
        # setup relations sheet
        wb.add_worksheet(name: "Relations") do |sheet|
          sheet.add_row ["Source", "Type", "Target", "Directed"], style: bold
          @relations.each do |relation|
            sheet.add_row [relation.source.name, relation.relation_type, relation.target.name, relation.direction ? nil : 0]
          end
        end
        send_data p.to_stream.read, type: "application/xlsx", filename: @visualization.name+".xlsx"
      end
    end
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

    unless params[:visualization][:dataset].nil?
      import_dataset(params[:visualization][:dataset], dataset)
    end

    if @visualization.save
      redirect_to visualization_path( @visualization ), :notice => "Your visualization was created!"
    else
      render :new
    end
  end

  # GET /visualizations/:id/edit
  def edit
    if current_user.nil?
      redirect_to new_user_session_path()
    else
      @visualization = Visualization.find(params[:id])
      @visualization_id = @visualization.id
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
    redirect_to user_path( current_user ), :flash => { :success => "Visualization deleted" }
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
    params.require(:visualization).permit(:name, :datasets)
  end

  def edit_info_params
    params.require(:visualization).permit(:name, :description)
  end

  def node_attributes
    [:name, :node_type, :description, :image, :custom_fields, :visible, :dataset]
  end

  def relation_attributes
    [:source, :target, :relation_type, :direction, :dataset]
  end

  def import_dataset( file, dataset )
    wb = Roo::Spreadsheet.open(file.path)

    # nodes
    sheet = wb.sheet('Nodes')
    headers = sheet.row(1)
    all_fields = headers.map{ |f| f.downcase.gsub(' ', '_').to_sym }
    regular_fields = [:name, :type, :description, :visible]
    custom_fields = all_fields - regular_fields
    dataset.custom_fields = custom_fields
    nodes = sheet.parse(header_search: headers, clean: true)[1..-1]
    nodes = nodes.map do |h|
      result = h.map { |k,v| [ !(k.capitalize=="Type") ? k.downcase.gsub(' ', '_').to_sym : :node_type, v ] }.to_h
      result[:custom_fields] = custom_fields.map{ |cf| [cf, result[cf]] }.to_h
      result[:visible] = result[:visible] == 0 ? false : true
      result[:dataset] = dataset
      result.slice(*node_attributes)
    end
    ActiveRecord::Base.transaction do
      Node.create(nodes)
    end

    # relations
    sheet = wb.sheet('Relations')
    headers = sheet.row(1)
    regular_fields = [:source, :relation_type, :target, :direction, :dataset]
    relations = sheet.parse(header_search: headers, clean: true)[1..-1]
    relations = relations.map do |h|
      result = h.map { |k,v| [ (k.capitalize=="Directed") ? :direction : (k.capitalize=="Type") ? :relation_type : k.downcase.gsub(' ', '_').to_sym, v ] }.to_h
      result[:source] = dataset.nodes.find_or_create_by(name: result[:source])
      result[:target] = dataset.nodes.find_or_create_by(name: result[:target])
      result[:direction] = result[:direction] == 0 ? false : true
      result[:dataset] = dataset
      result.slice(*relation_attributes)
    end
    ActiveRecord::Base.transaction do
      Relation.create(relations)
    end
  end

end
