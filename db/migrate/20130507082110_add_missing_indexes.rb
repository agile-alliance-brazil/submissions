class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :tracks, :conference_id
    add_index :activities, :room_id
    add_index :activities, [:detail_id, :detail_type]
    add_index :review_decisions, :session_id
    add_index :review_decisions, :organizer_id
    add_index :review_decisions, :outcome_id
    add_index :sessions, :track_id
    add_index :sessions, :author_id
    add_index :sessions, :session_type_id
    add_index :sessions, :second_author_id
    add_index :sessions, :audience_level_id
    add_index :sessions, :conference_id
    add_index :reviews, [:id, :type]
    add_index :reviews, :proposal_quality_rating_id
    add_index :reviews, :recommendation_id
    add_index :reviews, :proposal_relevance_rating_id
    add_index :reviews, :session_id
    add_index :reviews, :reviewer_confidence_rating_id
    add_index :reviews, :reviewer_id
    add_index :reviews, :author_agile_xp_rating_id
    add_index :reviews, :author_proposal_xp_rating_id
    add_index :rooms, :conference_id
    add_index :session_types, :conference_id
    add_index :votes, :session_id
    add_index :votes, :user_id
    add_index :votes, :conference_id
    add_index :votes, [:session_id, :user_id]
    add_index :guest_sessions, :conference_id
    add_index :audience_levels, :conference_id
    add_index :reviewers, :user_id
    add_index :reviewers, :conference_id
    add_index :organizers, :track_id
    add_index :organizers, :user_id
    add_index :organizers, :conference_id
    add_index :organizers, [:track_id, :user_id]
    add_index :preferences, :track_id
    add_index :preferences, :reviewer_id
    add_index :preferences, :audience_level_id
  end
end