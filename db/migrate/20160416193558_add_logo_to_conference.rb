# frozen_string_literal: true

class AddLogoToConference < ActiveRecord::Migration
  def change
    add_attachment :conferences, :logo
  end
end
