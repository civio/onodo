require 'axlsx'

class XlsxDatasetExporter

  def initialize(dataset)
    @nodes = dataset.nodes.order(:name)
    @relations = dataset.relations.includes(:source, :target).order('nodes.name', 'targets_relations.name')
    @node_custom_fields = dataset.node_custom_fields
    @relation_custom_fields = dataset.relation_custom_fields
  end

  def export
    package = Axlsx::Package.new

    workbook = package.workbook
    bold = workbook.styles.add_style b: true

    # setup nodes sheet
    workbook.add_worksheet(name: "Nodes") do |sheet|
      sheet.add_row nodes_header, style: bold
      @nodes.each do |node|
        sheet.add_row nodes_row(node)
      end
    end

    # setup relations sheet
    workbook.add_worksheet(name: "Relations") do |sheet|
      sheet.add_row relations_header, style: bold
      @relations.each do |relation|
        sheet.add_row relations_row(relation)
      end
    end

    package
  end

  private

  def nodes_header
    ["Name", "Type", "Description", "Visible"] +
        (@node_custom_fields || []).map { |cf| cf["name"].capitalize.gsub('_', ' ') }
  end

  def nodes_row(node)
    [node.name, node.node_type, node.description, node.visible ? nil : 0] +
        (@node_custom_fields || []).map { |cf| custom_fields = (node.custom_fields || {}); custom_fields[cf["name"]] }
  end

  def relations_header
    ["Source", "Type", "Target", "Directed", "At", "From", "To"] +
        (@relation_custom_fields || []).map { |cf| cf["name"].capitalize.gsub('_', ' ') }
  end

  def relations_row(relation)
    [relation.source && relation.source.name, relation.relation_type, relation.target && relation.target.name, relation.direction ? 1 : nil, relation.transient? ? (relation.at && relation.at.to_date) : nil, relation.transient? ? nil : (relation.from && relation.from.to_date), relation.transient? ? nil : (relation.to && relation.to.to_date)] +
        (@relation_custom_fields || []).map { |cf| custom_fields = (relation.custom_fields || {}); custom_fields[cf["name"]] }
  end

end