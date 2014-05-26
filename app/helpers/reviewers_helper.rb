# encoding: UTF-8
module ReviewersHelper
  def review_level(preferences, track)
    preference = preferences.select{ |pref| pref.track_id == track.id }.first
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
end
