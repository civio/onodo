require 'roo'

class XlsxDatasetImporter

  def initialize(xlsx_file)
    @workbook = Roo::Spreadsheet.open(xlsx_file.path)
  end

  def import
    if invalid_sheets?
      @error_message = "A nodes or a relations sheet must exist in the XLSX workbook."
      return nil
    end

    if invalid_node_columns?
      @error_message = "At least a name column musts exist in the XLSX nodes sheet."
      return nil
    end

    if invalid_relation_columns?
      @error_message = "At least source and target columns musts exist in the XLSX relations sheet."
      return nil
    end

    @nodes = create_nodes || []
    @relations = create_relations || []

    Dataset.new(nodes: @nodes, relations: @relations, custom_fields: @custom_fields)
  end

  def error_message
    @error_message
  end

  private

  def invalid_sheets?
    !(nodes_sheet? || relations_sheet?)
  end

  def invalid_node_columns?
    nodes_sheet? && !mandatory_node_columns.all?{ |c| !sheet_columns(nodes_sheet_name).grep(c).empty? }
  end

  def invalid_relation_columns?
    relations_sheet? && !mandatory_relation_columns.all?{ |c| !sheet_columns(relations_sheet_name).grep(c).empty? }
  end

  def node_attributes
    [:name, :node_type, :description, :image, :custom_fields, :visible]
  end

  def relation_attributes
    [:source, :target, :relation_type, :direction]
  end

  def nodes_sheet_name
    # node, nodes, nodo, nodos
    select_sheet(/nod[eo]s?$/i)
  end

  def sheet_columns(sheet_name)
    sheet = @workbook.sheet(sheet_name)
    sheet.row(1)
  end

  # def sheet_fields(sheet_name)
  #   sheet_columns(sheet_name).map{ |f| f.downcase.gsub(' ', '_').to_sym }
  # end

  def relations_sheet_name
    # relation, relations, relacion, relaciones
    select_sheet(/relations?$|relaci[oóòö]n(es)?$/i)
  end

  def select_sheet(name_selector)
    @workbook.sheets.grep(name_selector).first
  end

  def nodes_sheet?
    !nodes_sheet_name.nil?
  end

  def nodes_sheet
    @workbook.sheet(nodes_sheet_name)
  end

  def relations_sheet?
    !relations_sheet_name.nil?
  end

  def relations_sheet
    @workbook.sheet(relations_sheet_name)
  end

  def mandatory_node_columns
    [/^name$/i]
  end

  def optional_node_columns
    [/^type$/i, /^description$/i, /^visible$/i]
  end

  def node_columns
    mandatory_node_columns + optional_node_columns
  end

  def mandatory_relation_columns
    [/^source$/i, /^target$/i]
  end

  def optional_relation_columns
    [/^type$/i, /^directed$/i, /^date$/i]
  end

  def relations_columns
    mandatory_relation_columns + optional_relation_columns
  end

  def create_nodes
    return unless nodes_sheet?

    columns = sheet_columns(nodes_sheet_name)
    @custom_fields = columns.reject{ |f| node_columns.any?{ |c| f =~ c }}.map{ |f| f.downcase.gsub(' ', '_').to_sym }

    nodes = nodes_sheet.parse(header_search: columns, clean: false)[1..-1]
    nodes.map do |h|
      result = h.map { |k,v| [ !(k.capitalize=="Type") ? k.downcase.gsub(' ', '_').to_sym : :node_type, v ] }.to_h
      result[:custom_fields] = @custom_fields.map{ |cf| val = result[cf]; [cf, val.is_a?(Float) ? "%.#{val.truncate.to_s.size + 2}g" % val : val ] }.to_h
      result[:visible] = result[:visible] == 0 ? false : true
      Node.new(result.slice(*node_attributes))
    end
  end

  def create_relations
    return unless relations_sheet?

    columns = sheet_columns(relations_sheet_name)

    relations = relations_sheet.parse(header_search: columns, clean: false)[1..-1]
    relations.map do |h|
      result = h.map { |k,v| [ (k.capitalize=="Directed") ? :direction : (k.capitalize=="Type") ? :relation_type : k.downcase.gsub(' ', '_').to_sym, v ] }.to_h
      result[:source] = @nodes.find{ |n| n.name == result[:source] } || (m = Node.new(name: result[:source]); @nodes << m; m)
      result[:target] = @nodes.find{ |n| n.name == result[:target] } || (m = Node.new(name: result[:target]); @nodes << m; m)
      result[:direction] = result[:direction] == 0 ? false : true
      Relation.new(result.slice(*relation_attributes))
    end
  end
end