namespace :demoviz do
  desc "Clear stale demo visualizations"
  task clear: :environment do
    Visualization.where("updated_at < ?", 6.hours.ago).destroy_all(author: demo_user)
  end

  desc "Remove all demo visualizations"
  task purge: :environment do
    Visualization.destroy_all(author: demo_user)
  end
end

def demo_user
  User.find_by(name: 'demo')
end
