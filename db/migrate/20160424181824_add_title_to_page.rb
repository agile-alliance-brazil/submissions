# frozen_string_literal: true
class AddTitleToPage < ActiveRecord::Migration
  def change
    add_column :pages, :title, :string, null: false, default: ''
  end
end
