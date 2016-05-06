class RemoveStoryReferenceFromVisualizations < ActiveRecord::Migration
  def up
    Visualization.where.not(story_id: nil).find_each do |viz|
      Story.find(viz.story_id).update_attribute(:visualization_id, viz.id)
    end

    remove_reference :visualizations, :story
  end

  def down
    add_reference :visualizations, :story, index: true

    Story.find_each do |story|
      viz = story.visualization
      viz.update_attribute(:story_id, story.id)
    end
  end
end
