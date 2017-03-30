# frozen_string_literal: true

class AddShowInMenuOptionToPage < ActiveRecord::Migration
  def change
    add_column :pages, :show_in_menu, :boolean, default: false, null: false
  end
end
