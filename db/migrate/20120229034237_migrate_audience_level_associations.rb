class MigrateAudienceLevelAssociations < ActiveRecord::Migration
  def up
    ActiveRecord::Base.transaction do
      # Updating references from 2011 to new audience levels    
      Preference.joins(:reviewer).where(:accepted => true, :reviewers => {:conference_id => 2}).readonly(false).each do |preference|
        preference.update_attribute(:audience_level_id, preference.audience_level_id + 3)
      end
    
      Session.where(:conference_id => 2).each do |session|
        session.update_attribute(:audience_level_id, session.audience_level_id + 3)
      end
    end
  end

  def down
    ActiveRecord::Base.transaction do
      # Updating references from 2011 to old audience levels    
      Preference.joins(:reviewer).where(:accepted => true, :reviewers => {:conference_id => 2}).readonly(false).each do |preference|
        preference.update_attribute(:audience_level_id, preference.audience_level_id - 3)
      end
    
      Session.where(:conference_id => 2).each do |session|
        session.update_attribute(:audience_level_id, session.audience_level_id - 3)
      end
    end
  end
end
