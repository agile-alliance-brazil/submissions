class AddConferenceIdToSessionTypes < ActiveRecord::Migration
  def change
    add_column :session_types, :conference_id, :integer
  end
end
