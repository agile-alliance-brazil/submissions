class RenameTitleToNameInRecommendations < ActiveRecord::Migration
  def change
    rename_column :recommendations, :title, :name
    Recommendation.all.each do |recommendation|
      if recommendation.name.match(/recommendation\.([^\.]*)\.title/)
        recommendation.name = $1
        recommendation.save
      end
    end
  end
end
