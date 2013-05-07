# encoding: UTF-8
class Comment < ActiveRecord::Base
  include ActsAsCommentable::Comment

  attr_accessible :comment, :user_id, :commentable_id
  attr_trimmed    :comment

  belongs_to :commentable, :polymorphic => true, :counter_cache => true
  belongs_to :user

  validates :comment, :presence => true, :length => {:maximum => 1000}
  validates :user_id, :presence => true
  validates :commentable_id, :presence => true

  default_scope :order => 'created_at ASC'
end
