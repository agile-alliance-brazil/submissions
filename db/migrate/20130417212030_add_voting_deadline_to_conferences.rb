# frozen_string_literal: true
class AddVotingDeadlineToConferences < ActiveRecord::Migration
  def change
    add_column :conferences, :voting_deadline, :datetime
  end
end
