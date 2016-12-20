# encoding: UTF-8
# frozen_string_literal: true
class Rating < ActiveRecord::Base
  validates :title, presence: true
end
