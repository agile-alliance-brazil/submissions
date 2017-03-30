# frozen_string_literal: true

class AddAllowFreeFormTagsToConferences < ActiveRecord::Migration
  def change
    add_column :conferences, :allow_free_form_tags, :boolean, default: true, null: false
  end
end
