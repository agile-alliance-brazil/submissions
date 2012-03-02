class MigrateSessionTypeAssociations < ActiveRecord::Migration
  def up
    ActiveRecord::Base.transaction do
      # Updating references from 2011 to new session types
      Session.where(:conference_id => 2).each do |session|
        session.update_attribute(:session_type_id, session.session_type_id + 3)
      end
    end
  end

  def down
    ActiveRecord::Base.transaction do
      # Updating references from 2011 to old session types
      Session.where(:conference_id => 2).each do |session|
        session.update_attribute(:session_type_id, session.session_type_id - 3)
      end
    end
  end
end
