class RenameSessionReviewsCount < ActiveRecord::Migration
  def up
    rename_column :sessions, :reviews_count, :final_reviews_count
  end

  def down
    rename_column :sessions, :final_reviews_count, :reviews_count
  end
end
