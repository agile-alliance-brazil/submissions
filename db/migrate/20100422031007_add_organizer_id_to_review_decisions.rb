# encoding: UTF-8
class AddOrganizerIdToReviewDecisions < ActiveRecord::Migration
  def self.up
    add_column :review_decisions, :organizer_id, :integer
  end

  def self.down
    remove_column :review_decisions, :organizer_id
  end
end
