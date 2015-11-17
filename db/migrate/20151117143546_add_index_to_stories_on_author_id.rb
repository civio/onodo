class AddIndexToStoriesOnAuthorId < ActiveRecord::Migration
  def change
    add_index :stories, :author_id
  end
end
