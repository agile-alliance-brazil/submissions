# encoding: UTF-8
# frozen_string_literal: true

class Outcome < ActiveRecord::Base
  validates :title, presence: true

  has_many :review_decisions
end
