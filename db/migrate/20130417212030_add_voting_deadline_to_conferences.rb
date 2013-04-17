class AddVotingDeadlineToConferences < ActiveRecord::Migration
  def change
    add_column :conferences, :voting_deadline, :datetime
  end
end
