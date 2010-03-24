class AddReviewsCountToSessions < ActiveRecord::Migration
  def self.up
    add_column :sessions, :reviews_count, :integer, :default => 0

    Session.reset_column_information
    Session.all.each do |s|
      Session.update_counters s.id, :reviews_count => s.reviews.length
    end
  end

  def self.down
    remove_column :sessions, :reviews_count
  end
end
