class AddPublishedToReviewDecisions < ActiveRecord::Migration
  def self.up
    add_column :review_decisions, :published, :boolean, :default => false
  end

  def self.down
    remove_column :review_decisions, :published
  end
end
