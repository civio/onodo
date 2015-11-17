class AddAuthorToVisualizations < ActiveRecord::Migration
  def change
    add_column :visualizations, :author_id, :integer, references: :users
  end
end
