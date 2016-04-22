class AddSignReviewOptionToReviewers < ActiveRecord::Migration
  def change
    add_column :reviewers, :sign_reviews, :boolean, column_options: { null: false }
  end
end
