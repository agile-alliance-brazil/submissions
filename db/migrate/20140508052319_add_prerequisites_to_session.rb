# frozen_string_literal: true

# rubocop:disable Rails/ReversibleMigration
class AddPrerequisitesToSession < ActiveRecord::Migration
  def change
    add_column :sessions, :prerequisites, :string
    execute 'update sessions set prerequisites="Este campo foi criado na AgileBrazil 2014"'
  end
end
# rubocop:enable Rails/ReversibleMigration
