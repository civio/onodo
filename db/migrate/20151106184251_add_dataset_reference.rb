class AddDatasetReference < ActiveRecord::Migration
  def change
    add_reference :datasets, :visualization, index: true
  end
end
