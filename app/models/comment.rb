class Comment < ActiveRecord::Base
  include ActsAsCommentable::Comment

  attr_accessible :comment, :user_id, :commentable_id
  attr_trimmed    :comment

  belongs_to :commentable, :polymorphic => true
  belongs_to :user

  validates_presence_of :comment, :user_id, :commentable_id
  validates_length_of :comment, :maximum => 1000

  default_scope :order => 'created_at ASC'
end
