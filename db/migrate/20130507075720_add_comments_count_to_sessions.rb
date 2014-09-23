class AddCommentsCountToSessions < ActiveRecord::Migration
  def change
    add_column :sessions, :comments_count, :integer, default: 0
  end
end
