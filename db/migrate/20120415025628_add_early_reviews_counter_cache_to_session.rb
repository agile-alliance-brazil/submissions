class AddEarlyReviewsCounterCacheToSession < ActiveRecord::Migration
  def change
    add_column :sessions, :early_reviews_count, :integer, :default => 0

    # Resetting Luca's review
    begin
      review = Review.find(1023)
      review.update_attribute(:type, 'EarlyReview')
      review = EarlyReview.find(1023)
      review.update_attribute(:justification, '')
      review.update_attribute(:recommendation_id, nil)

      session = review.session
      last_updated = session.updated_at
      session.update_attribute(:state, 'created')
      session.update_attribute(:final_reviews_count, 0)
      session.update_attribute(:updated_at, last_updated)
    rescue ActiveRecord::RecordNotFound
    end

    Session.reset_column_information
    EarlyReview.reset_column_information
    FinalReview.reset_column_information
    Session.all.each do |s|
      Session.update_counters s.id, :early_reviews_count => s.early_reviews.length, :final_reviews_count => s.final_reviews.length
    end
  end
end
