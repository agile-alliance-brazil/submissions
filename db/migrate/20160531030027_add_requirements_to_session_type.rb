class AddRequirementsToSessionType < ActiveRecord::Migration
  def change
    add_column :session_types, :needs_audience_limit, :bool, default: false, null: false
    add_column :session_types, :needs_mechanics, :bool, default: false, null: false
  end
end
