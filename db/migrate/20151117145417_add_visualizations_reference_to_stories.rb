class AddVisualizationsReferenceToStories < ActiveRecord::Migration
  def change
    add_reference :visualizations, :story, index: true
  end
end
