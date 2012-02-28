class AddConferenceIdToTrack < ActiveRecord::Migration
  def change
    add_column :tracks, :conference_id, :integer
  end
end
