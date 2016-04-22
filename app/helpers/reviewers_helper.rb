# encoding: UTF-8
module ReviewersHelper
  def review_level(preferences, track)
    preference = preferences.select { |pref| pref.track_id == track.id }.first
    if preference
       preference.audience_level.title
    else
      'reviewer.doesnot_review'
     end
  end

  def build_hash_with_reviewers_and_comments reviews, conference
  	reviewers, comments = {}, {}
		reviews.each_with_index do |review, index|
		  reviewer = review.reviewer.reviewer_for(conference)
		  reviewers[review] = reviewer.display_name(index + 1)
		  comments[review] = review.comments_to_authors
		end
		[reviewers, comments]
  end

  def reviewer_summary_review_row(reviews, conference)
    row = Recommendation.all_names.
      map {|r| Recommendation.where(name: r).select(:id).map(&:id)}.
      map {|ids| reviews.select {|r| ids.include?(r.recommendation_id)}.count}
    feedback_summary = ''
    if conference.author_notification.past?
      evaluations = ReviewEvaluation.where(review_id: reviews.map(&:id)).to_a
      feedback_summary = evaluations.select(&:helpful_review).size.to_s + image_tag('helpful.png', alt: '👍') + ' ' +
        evaluations.reject(&:helpful_review).size.to_s + image_tag('not-helpful.png', alt: '👎')
    end
    row << feedback_summary
    row
  end

  def review_feedback_score(review)
    helpful, not_helpful = review.review_evaluations.partition(&:helpful_review)
    (not_helpful.size * 10) + helpful.size
  end
end
