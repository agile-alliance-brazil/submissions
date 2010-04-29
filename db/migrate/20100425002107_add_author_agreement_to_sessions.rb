class AddAuthorAgreementToSessions < ActiveRecord::Migration
  def self.up
    add_column :sessions, :author_agreement, :boolean
    add_column :sessions, :image_agreement, :boolean
  end

  def self.down
    remove_column :sessions, :author_agreement
    remove_column :sessions, :image_agreement
  end
end
