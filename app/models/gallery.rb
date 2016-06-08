class Gallery < ActiveRecord::Base
  acts_as_singleton

  def visualizations
    Visualization.find(visualization_ids)
  end

  def stories
   Story.find(story_ids)
  end
end
