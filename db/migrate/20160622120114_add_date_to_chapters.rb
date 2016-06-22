class AddDateToChapters < ActiveRecord::Migration
  def change
    add_column :chapters, :date_from, :date
    add_column :chapters, :date_to, :date
  end
end
