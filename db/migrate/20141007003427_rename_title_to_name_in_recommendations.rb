# frozen_string_literal: true

class RenameTitleToNameInRecommendations < ActiveRecord::Migration
  def change
    rename_column :recommendations, :title, :name
    Recommendation.all.each do |recommendation|
      if recommendation.name =~ /recommendation\.([^\.]*)\.title/
        recommendation.name = Regexp.last_match(1)
        recommendation.save
      end
    end
  end
end
