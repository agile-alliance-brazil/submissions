class AddPresubmissionAndPrereviewDeadlinesToConferences < ActiveRecord::Migration
  def change
    add_column :conferences, :presubmissions_deadline, :datetime
    add_column :conferences, :prereview_deadline, :datetime
  end
end
