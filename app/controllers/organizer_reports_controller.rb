# encoding: UTF-8
# frozen_string_literal: true

class OrganizerReportsController < ApplicationController
  def index
    track_ids = current_user.organized_tracks(@conference).select(:id).map(&:id)
    @sessions = Session.for_conference(@conference).for_tracks(track_ids)
                       .includes(
                         :track,
                         :session_type,
                         :audience_level,
                         :author,
                         :second_author,
                         final_reviews: %i(
                           reviewer
                           author_agile_xp_rating
                           author_proposal_xp_rating
                           proposal_quality_rating
                           proposal_relevance_rating
                           recommendation
                           reviewer_confidence_rating
                         )
                       )

    respond_to do |format|
      format.xls
    end
  end
end
