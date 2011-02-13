class CreateConferences < ActiveRecord::Migration
  def self.up
    create_table :conferences do |t|
      t.string  :name
      t.integer :year

      t.timestamps
    end

    add_column :organizers, :conference_id, :integer
    add_column :reviewers, :conference_id, :integer
    add_column :sessions, :conference_id, :integer
    add_column :slots, :conference_id, :integer

    Conference.transaction do
      agile_brazil_2010 = Conference.create(:name => "Agile Brazil 2010", :year => 2010)

      Organizer.update_all :conference_id => agile_brazil_2010.id
      Reviewer.update_all :conference_id => agile_brazil_2010.id
      Session.update_all :conference_id => agile_brazil_2010.id
      Slot.update_all :conference_id => agile_brazil_2010.id
    end
  end

  def self.down
    remove_column :organizers, :conference_id
    remove_column :reviewers, :conference_id
    remove_column :sessions, :conference_id
    remove_column :slots, :conference_id
    drop_table :conferences
  end
end
