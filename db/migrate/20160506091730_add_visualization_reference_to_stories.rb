class AddVisualizationReferenceToStories < ActiveRecord::Migration
  def change
    add_reference :stories, :visualization, index: true
  end
end
