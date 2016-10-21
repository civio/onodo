require 'roo'

class XlsxDatasetImporter
  include TypeUtil

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

    node_custom_fields = @node_custom_field_names && @node_custom_field_names.map{ |cfn| { "name" => cfn.to_s, "type" => type_for(@nodes.map{ |n| n.custom_fields[cfn.to_s] }) } }
    relation_custom_fields = @relation_custom_field_names && @relation_custom_field_names.map{ |cfn| { "name" => cfn.to_s, "type" => type_for(@relations.map{ |n| n.custom_fields[cfn.to_s] }) } }

    Dataset.new(nodes: @nodes, relations: @relations, node_custom_fields: node_custom_fields, relation_custom_fields: relation_custom_fields)
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
    [:source, :target, :relation_type, :direction, :custom_fields, :at, :from, :to]
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
    [/^type$/i, /^directed$/i, /(^at$)|(^date)/i, /^from$/i, /^to$/i]
  end

  def relation_columns
    mandatory_relation_columns + optional_relation_columns
  end

  def create_nodes
    return unless nodes_sheet?

    columns = sheet_columns(nodes_sheet_name)
    @node_custom_field_names = columns.reject{ |f| node_columns.any?{ |c| f =~ c }}.map{ |f| f.downcase.gsub(' ', '_').to_sym }

    nodes = nodes_sheet.parse(header_search: columns, clean: false)[1..-1]
    nodes = nodes.map do |h|
      h["Name"] = h["Name"].to_i.to_s if h["Name"].is_a? Numeric
      result = h.map { |k,v| [ !(k.capitalize=="Type") ? k.downcase.gsub(' ', '_').to_sym : :node_type, v.is_a?(String) ? v.strip : v ] }.to_h
      result[:custom_fields] = @node_custom_field_names.map{ |cf| val = result[cf]; [cf, val.is_a?(Float) ? "%.#{val.truncate.to_s.size + 2}g" % val : val ] }.to_h
      result[:visible] = result[:visible] == 0 ? false : true
      Node.new(result.slice(*node_attributes))
    end
    deduplicate_nodes(nodes)
  end

  def create_relations
    return unless relations_sheet?

    columns = sheet_columns(relations_sheet_name)
    @relation_custom_field_names = columns.reject{ |f| relation_columns.any?{ |c| f =~ c }}.map{ |f| f.downcase.gsub(' ', '_').to_sym }

    relations = relations_sheet.parse(header_search: columns, clean: false)[1..-1]
    relations = relations.map do |h|
      h["Source"] = h["Source"].to_i.to_s if h["Source"].is_a? Numeric
      h["Target"] = h["Target"].to_i.to_s if h["Target"].is_a? Numeric
      result = h.map { |k,v| [ (k.capitalize=="Directed") ? :direction : (k.capitalize=="Type") ? :relation_type : (k.capitalize=="Date") ? :at : k.downcase.gsub(' ', '_').to_sym, v.is_a?(String) ? v.strip : v ] }.to_h
      result[:source] = @nodes.find{ |n| n.name == result[:source] } || (m = Node.new(name: result[:source]); @nodes << m; m)
      result[:target] = @nodes.find{ |n| n.name == result[:target] } || (m = Node.new(name: result[:target]); @nodes << m; m)
      result[:custom_fields] = @relation_custom_field_names.map{ |cf| val = result[cf]; [cf, val.is_a?(Float) ? "%.#{val.truncate.to_s.size + 2}g" % val : val ] }.to_h
      result[:direction] = result[:direction] == 1 ? true : false
      result[:at] = result[:at].to_s
      result[:from] = result[:from].to_s
      result[:to] = result[:to].to_s
      Relation.new(result.slice(*relation_attributes))
    end
    deduplicate_relations(relations)
  end

  def deduplicate_nodes(nodes)
    result = []
    nodes.each do |node|
      n = result.find{ |n| n[:name] == node[:name] }
      if n
        merge_nodes(n, node)
        next
      else
        result << node
      end
    end
    result
  end

  def merge_nodes(existing, duplicated)
    editable_attributes = [:description, :visible, :node_type]
    editable_attributes.each do |attr|
      existing[attr] = duplicated[attr] unless duplicated[attr].nil?
    end
    duplicated[:custom_fields].keys.each do |cf|
      existing[:custom_fields][cf] = duplicated[:custom_fields][cf] unless duplicated[:custom_fields][cf].nil?
    end
  end

  def deduplicate_relations(relations)
    result = []
    relations.each do |relation|
      r = result.find{ |r| r.source == relation.source && r.target == relation.target && r.relation_type == relation.relation_type }
      if r
        next
      else
        result << relation
      end
    end
    result
  end
end
