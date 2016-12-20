# frozen_string_literal: true
class ChangeCommentToTextInReviewEvaluation < ActiveRecord::Migration
  def up
    change_column :review_evaluations, :comments, :text
  end

  def down
    change_column :review_evaluations, :comments, :string
  end
end
