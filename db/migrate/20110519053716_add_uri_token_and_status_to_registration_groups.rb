# encoding: UTF-8
class AddUriTokenAndStatusToRegistrationGroups < ActiveRecord::Migration
  def self.up
    add_column :registration_groups, :uri_token, :string
    add_column :registration_groups, :status, :string

    # There no registration group anymore
    # RegistrationGroup.all.each do |group|
    #   group.send(:generate_uri_token)
    #   group.status = 'incomplete'
    #   if group.complete
    #     group.confirm if group.attendees.all?(&:confirmed?)
    #   end
    #   group.save!(:validate => false)
    # end
  end

  def self.down
    remove_column :registration_groups, :status
    remove_column :registration_groups, :uri_token
  end
end
