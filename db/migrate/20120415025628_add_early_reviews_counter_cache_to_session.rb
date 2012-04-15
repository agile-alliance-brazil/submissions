class AddEarlyReviewsCounterCacheToSession < ActiveRecord::Migration
  def change
    add_column :sessions, :early_reviews_count, :integer, :default => 0

    Session.reset_column_information
    Session.all.each do |s|
      Session.update_counters s.id, :early_reviews_count => s.early_reviews.length
      Session.update_counters s.id, :final_reviews_count => s.final_reviews.length
    end
  end
end
