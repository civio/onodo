class Gallery < ActiveRecord::Base
  acts_as_singleton

  def visualizations
    Visualization.where(id: visualization_ids)
  end

  def stories
   Story.where(id: story_ids)
  end
end
