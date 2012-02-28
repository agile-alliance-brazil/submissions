class MigrateTrackAssociations < ActiveRecord::Migration
  def up
    ActiveRecord::Base.transaction do
      # Updating references from 2011 to new tracks
      Organizer.where(:conference_id => 2).each do |organizer|
        organizer.update_attribute(:track_id, organizer.track_id + 4)
      end
    
      # Cleanup orphan preferences
      Preference.where(["reviewer_id NOT IN (?)", Reviewer.all.map(&:id)]).each do |preference|
        preference.destroy
      end
    
      Preference.joins(:reviewer).where(:reviewers => {:conference_id => 2}).readonly(false).each do |preference|
        preference.update_attribute(:track_id, preference.track_id + 4)
      end
    
      Session.where(:conference_id => 2).each do |session|
        session.update_attribute(:track_id, session.track_id + 4)
      end
    end
  end

  def down
    ActiveRecord::Base.transaction do
      # Updating references from 2011 to old tracks
      Organizer.where(:conference_id => 2).each do |organizer|
        organizer.update_attribute(:track_id, organizer.track_id - 4)
      end
    
      Preference.joins(:reviewer).where(:reviewers => {:conference_id => 2}).readonly(false).each do |preference|
        preference.update_attribute(:track_id, preference.track_id - 4)
      end
    
      Session.where(:conference_id => 2).each do |session|
        session.update_attribute(:track_id, session.track_id - 4)
      end
    end
  end
end
