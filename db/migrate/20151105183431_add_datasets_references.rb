class AddDatasetsReferences < ActiveRecord::Migration
  def change
    add_reference :nodes, :dataset, index: true
    add_reference :relations, :dataset, index: true
  end
end
