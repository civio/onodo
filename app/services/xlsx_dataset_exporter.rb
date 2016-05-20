require 'axlsx'

class XlsxDatasetExporter

  def initialize(dataset)
    @nodes = dataset.nodes.order(:name)
    @relations = dataset.relations.includes(:source, :target).order('nodes.name', 'targets_relations.name')
    @custom_fields = dataset.custom_fields
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
    ["Name", "Type", "Description", "Visible"] + (@custom_fields || []).map { |cf| cf.capitalize.gsub('_', ' ') }
  end

  def nodes_row(node)
    [node.name, node.node_type, node.description, node.visible ? nil : 0] + (@custom_fields || []).map { |cf| custom_fields = (node.custom_fields || {}); custom_fields[cf] }
  end

  def relations_header
    ["Source", "Type", "Target", "Directed"]
  end

  def relations_row(relation)
    [relation.source.name, relation.relation_type, relation.target.name, relation.direction ? nil : 0]
  end

end