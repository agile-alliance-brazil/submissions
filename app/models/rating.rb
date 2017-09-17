# frozen_string_literal: true

class Rating < ApplicationRecord
  validates :title, presence: true
end
