# frozen_string_literal: true
class AddLanguageToSession < ActiveRecord::Migration
  def change
    add_column :sessions, :language, :string
  end
end
