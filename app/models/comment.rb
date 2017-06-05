# encoding: UTF-8
# frozen_string_literal: true

class Comment < ApplicationRecord
  include ActsAsCommentable::Comment

  attr_trimmed :comment

  belongs_to :commentable, polymorphic: true, counter_cache: true
  belongs_to :user

  validates :comment, presence: true, length: { maximum: 1000 }
  validates :user_id, presence: true
  validates :commentable_type, presence: true
  validates :commentable_id, presence: true

  default_scope(-> { order('created_at ASC') })
end
