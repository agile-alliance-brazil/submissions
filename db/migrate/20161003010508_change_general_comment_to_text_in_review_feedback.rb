# frozen_string_literal: true
class ChangeGeneralCommentToTextInReviewFeedback < ActiveRecord::Migration
  def up
    change_column :review_feedbacks, :general_comments, :text
  end

  def down
    change_column :review_feedbacks, :general_comments, :string
  end
end
