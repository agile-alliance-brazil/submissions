# frozen_string_literal: true
class AddRequirementsToSessionType < ActiveRecord::Migration
  def change
    add_column :session_types, :needs_audience_limit, :boolean, default: false, null: false
    add_column :session_types, :needs_mechanics, :boolean, default: false, null: false
  end
end
