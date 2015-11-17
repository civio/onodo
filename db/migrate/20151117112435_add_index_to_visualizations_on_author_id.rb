class AddIndexToVisualizationsOnAuthorId < ActiveRecord::Migration
  def change
    add_index :visualizations, :author_id
  end
end
