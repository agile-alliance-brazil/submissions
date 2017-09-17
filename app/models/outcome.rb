# frozen_string_literal: true

class Outcome < ApplicationRecord
  validates :title, presence: true

  has_many :review_decisions, dependent: :restrict_with_exception
end
