# encoding: UTF-8
class AddContentToConference < ActiveRecord::Migration
  def self.up
    add_column :conferences, :call_for_papers, :datetime
    add_column :conferences, :submissions_open, :datetime
    add_column :conferences, :submissions_deadline, :datetime
    add_column :conferences, :review_deadline, :datetime
    add_column :conferences, :author_notification, :datetime
    add_column :conferences, :author_confirmation, :datetime

    ab2010 = Conference.where(:year => 2010).first
    ab2010.call_for_papers = Time.zone.local(2010, 1, 31)
    ab2010.submissions_open = Time.zone.local(2010, 1, 31)
    ab2010.submissions_deadline = Time.zone.local(2010, 3, 7)
    ab2010.review_deadline = Time.zone.local(2010, 4, 23)
    ab2010.author_notification = Time.zone.local(2010, 5, 3)
    ab2010.author_confirmation = Time.zone.local(2010, 5, 17)
    ab2010.save!

    ab2011 = Conference.where(:year => 2011).first
    ab2011.call_for_papers = Time.zone.local(2011, 2, 5)
    ab2011.submissions_open = Time.zone.local(2010, 2, 14)
    ab2011.submissions_deadline = Time.zone.local(2010, 3, 27)
    ab2010.review_deadline = Time.zone.local(2010, 4, 17)
    ab2011.author_notification = Time.zone.local(2010, 4, 30)
    ab2011.author_confirmation = Time.zone.local(2010, 6, 7)
    ab2011.save!
  end

  def self.down
    remove_column :conferences, :call_for_papers
    remove_column :conferences, :submissions_open
    remove_column :conferences, :submissions_deadline
    remove_column :conferences, :author_notification
    remove_column :conferences, :author_confirmation
  end
end
