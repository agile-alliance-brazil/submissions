class AddInfoToConference < ActiveRecord::Migration
  def up
    add_column :conferences, :call_for_papers, :datetime
    add_column :conferences, :submissions_open, :datetime
    add_column :conferences, :submissions_deadline, :datetime
    add_column :conferences, :review_deadline, :datetime
    add_column :conferences, :author_notification, :datetime
    add_column :conferences, :author_confirmation, :datetime
    add_column :conferences, :location_and_date, :string
  end

  def down
    remove_column :conferences, :call_for_papers
    remove_column :conferences, :submissions_open
    remove_column :conferences, :submissions_deadline
    remove_column :conferences, :author_notification
    remove_column :conferences, :author_confirmation
    remove_column :conferences, :location_and_date
  end
end
