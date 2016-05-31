class CreateReviewFeedbacks < ActiveRecord::Migration
  def change
    create_table :review_feedbacks do |t|
      t.references  :conference
      t.references  :author
      t.string  :general_comments

      t.timestamps null: false
    end
    create_table :review_evaluations do |t|
      t.references  :review
      t.references  :review_feedback
      t.boolean  :helpful_review
      t.string   :comments

      t.timestamps null: false
    end
  end
end
