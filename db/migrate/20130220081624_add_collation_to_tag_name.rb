# frozen_string_literal: true
class AddCollationToTagName < ActiveRecord::Migration
  def change
    execute 'ALTER TABLE tags MODIFY name VARCHAR(255) DEFAULT NULL COLLATE utf8_bin' if connection.adapter_name =~ /mysql/i
  end
end
