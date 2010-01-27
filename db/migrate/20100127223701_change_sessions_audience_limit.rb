class ChangeSessionsAudienceLimit < ActiveRecord::Migration
  def self.up
    change_column :sessions, :audience_limit, :integer
    Session.update_all('audience_limit = NULL')
  end

  def self.down
    change_column :sessions, :audience_limit, :string
  end
end
