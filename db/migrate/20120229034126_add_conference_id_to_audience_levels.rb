class AddConferenceIdToAudienceLevels < ActiveRecord::Migration
  def change
    add_column :audience_levels, :conference_id, :integer
  end
end
