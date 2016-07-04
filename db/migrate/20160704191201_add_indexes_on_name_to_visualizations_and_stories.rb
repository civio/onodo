class AddIndexesOnNameToVisualizationsAndStories < ActiveRecord::Migration

  # def up
  #   execute "CREATE INDEX index_visualizations_on_name ON visualizations USING gin (name gin_trgm_ops)"
  #   execute "CREATE INDEX index_stories_on_name ON stories USING gin (name gin_trgm_ops)"
  # end
  #
  # def down
  #   execute "DROP INDEX index_stories_on_name"
  #   execute "DROP INDEX index_visualizations_on_name"
  # end

  def change
    add_index :visualizations, :name, using: :gin, opclasses: { name: :gin_trgm_ops }
    add_index :stories, :name, using: :gin, opclasses: { name: :gin_trgm_ops }
  end
end
