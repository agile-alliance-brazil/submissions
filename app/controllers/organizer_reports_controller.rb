# encoding: UTF-8
class OrganizerReportsController < InheritedResources::Base
  defaults resource_class: Session
  actions :index
  respond_to :xls

  protected
  def collection
    tracks = current_user.organized_tracks(@conference)
    @sessions ||= end_of_association_chain.
                  for_conference(@conference).
                  for_tracks(tracks.map(&:id)).
                  includes(
                    :track,
                    :session_type,
                    :audience_level,
                    :author,
                    :second_author,
                    final_reviews: [
                      :reviewer,
                      :author_agile_xp_rating,
                      :author_proposal_xp_rating,
                      :proposal_quality_rating,
                      :proposal_relevance_rating,
                      :recommendation,
                      :reviewer_confidence_rating
                    ]
                  )
  end
end
