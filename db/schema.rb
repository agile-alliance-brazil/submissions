# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130612053215) do

  create_table "activities", :force => true do |t|
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "room_id"
    t.integer  "detail_id"
    t.string   "detail_type"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "roomspan",    :default => 1
  end

  add_index "activities", ["detail_id", "detail_type"], :name => "index_activities_on_detail_id_and_detail_type"
  add_index "activities", ["room_id"], :name => "index_activities_on_room_id"

  create_table "all_hands", :force => true do |t|
    t.string   "title"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "audience_levels", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.integer  "conference_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "audience_levels", ["conference_id"], :name => "index_audience_levels_on_conference_id"

  create_table "client_applications", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "support_url"
    t.string   "callback_url"
    t.string   "key",          :limit => 40
    t.string   "secret",       :limit => 40
    t.integer  "user_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "client_applications", ["key"], :name => "index_client_applications_on_key", :unique => true

  create_table "comments", :force => true do |t|
    t.text     "comment",          :default => ""
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "conferences", :force => true do |t|
    t.string   "name"
    t.integer  "year"
    t.datetime "call_for_papers"
    t.datetime "submissions_open"
    t.datetime "submissions_deadline"
    t.datetime "review_deadline"
    t.datetime "author_notification"
    t.datetime "author_confirmation"
    t.string   "location_and_date"
    t.datetime "presubmissions_deadline"
    t.datetime "prereview_deadline"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.datetime "voting_deadline"
  end

  create_table "guest_sessions", :force => true do |t|
    t.string   "title"
    t.string   "author"
    t.text     "summary"
    t.integer  "conference_id"
    t.boolean  "keynote",       :default => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "guest_sessions", ["conference_id"], :name => "index_guest_sessions_on_conference_id"

  create_table "lightning_talk_groups", :force => true do |t|
    t.string   "lightning_talk_info"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "oauth_access_grants", :force => true do |t|
    t.integer  "resource_owner_id", :null => false
    t.integer  "application_id",    :null => false
    t.string   "token",             :null => false
    t.integer  "expires_in",        :null => false
    t.string   "redirect_uri",      :null => false
    t.datetime "created_at",        :null => false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], :name => "index_oauth_access_grants_on_token", :unique => true

  create_table "oauth_access_tokens", :force => true do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id",    :null => false
    t.string   "token",             :null => false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        :null => false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], :name => "index_oauth_access_tokens_on_refresh_token", :unique => true
  add_index "oauth_access_tokens", ["resource_owner_id"], :name => "index_oauth_access_tokens_on_resource_owner_id"
  add_index "oauth_access_tokens", ["token"], :name => "index_oauth_access_tokens_on_token", :unique => true

  create_table "oauth_applications", :force => true do |t|
    t.string   "name",         :null => false
    t.string   "uid",          :null => false
    t.string   "secret",       :null => false
    t.string   "redirect_uri", :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "oauth_applications", ["uid"], :name => "index_oauth_applications_on_uid", :unique => true

  create_table "oauth_nonces", :force => true do |t|
    t.string   "nonce"
    t.integer  "timestamp"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "oauth_nonces", ["nonce", "timestamp"], :name => "index_oauth_nonces_on_nonce_and_timestamp", :unique => true

  create_table "oauth_tokens", :force => true do |t|
    t.integer  "user_id"
    t.string   "type",                  :limit => 20
    t.integer  "client_application_id"
    t.string   "token",                 :limit => 40
    t.string   "secret",                :limit => 40
    t.string   "callback_url"
    t.string   "verifier",              :limit => 20
    t.string   "scope"
    t.datetime "authorized_at"
    t.datetime "invalidated_at"
    t.datetime "expires_at"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  add_index "oauth_tokens", ["token"], :name => "index_oauth_tokens_on_token", :unique => true

  create_table "organizers", :force => true do |t|
    t.integer  "user_id"
    t.integer  "track_id"
    t.integer  "conference_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "organizers", ["conference_id"], :name => "index_organizers_on_conference_id"
  add_index "organizers", ["track_id", "user_id"], :name => "index_organizers_on_track_id_and_user_id"
  add_index "organizers", ["track_id"], :name => "index_organizers_on_track_id"
  add_index "organizers", ["user_id"], :name => "index_organizers_on_user_id"

  create_table "outcomes", :force => true do |t|
    t.string   "title"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "preferences", :force => true do |t|
    t.integer  "reviewer_id"
    t.integer  "track_id"
    t.integer  "audience_level_id"
    t.boolean  "accepted",          :default => false
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  add_index "preferences", ["audience_level_id"], :name => "index_preferences_on_audience_level_id"
  add_index "preferences", ["reviewer_id"], :name => "index_preferences_on_reviewer_id"
  add_index "preferences", ["track_id"], :name => "index_preferences_on_track_id"

  create_table "ratings", :force => true do |t|
    t.string   "title"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "recommendations", :force => true do |t|
    t.string   "title"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "review_decisions", :force => true do |t|
    t.integer  "session_id"
    t.integer  "outcome_id"
    t.integer  "organizer_id"
    t.text     "note_to_authors"
    t.boolean  "published",       :default => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "review_decisions", ["organizer_id"], :name => "index_review_decisions_on_organizer_id"
  add_index "review_decisions", ["outcome_id"], :name => "index_review_decisions_on_outcome_id"
  add_index "review_decisions", ["session_id"], :name => "index_review_decisions_on_session_id"

  create_table "reviewers", :force => true do |t|
    t.integer  "user_id"
    t.integer  "conference_id"
    t.string   "state"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "reviewers", ["conference_id"], :name => "index_reviewers_on_conference_id"
  add_index "reviewers", ["user_id"], :name => "index_reviewers_on_user_id"

  create_table "reviews", :force => true do |t|
    t.integer  "author_agile_xp_rating_id"
    t.integer  "author_proposal_xp_rating_id"
    t.boolean  "proposal_track"
    t.boolean  "proposal_level"
    t.boolean  "proposal_type"
    t.boolean  "proposal_duration"
    t.boolean  "proposal_limit"
    t.boolean  "proposal_abstract"
    t.integer  "proposal_quality_rating_id"
    t.integer  "proposal_relevance_rating_id"
    t.integer  "recommendation_id"
    t.text     "justification"
    t.integer  "reviewer_confidence_rating_id"
    t.text     "comments_to_organizers"
    t.text     "comments_to_authors"
    t.integer  "reviewer_id"
    t.integer  "session_id"
    t.string   "type"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "reviews", ["author_agile_xp_rating_id"], :name => "index_reviews_on_author_agile_xp_rating_id"
  add_index "reviews", ["author_proposal_xp_rating_id"], :name => "index_reviews_on_author_proposal_xp_rating_id"
  add_index "reviews", ["id", "type"], :name => "index_reviews_on_id_and_type"
  add_index "reviews", ["proposal_quality_rating_id"], :name => "index_reviews_on_proposal_quality_rating_id"
  add_index "reviews", ["proposal_relevance_rating_id"], :name => "index_reviews_on_proposal_relevance_rating_id"
  add_index "reviews", ["recommendation_id"], :name => "index_reviews_on_recommendation_id"
  add_index "reviews", ["reviewer_confidence_rating_id"], :name => "index_reviews_on_reviewer_confidence_rating_id"
  add_index "reviews", ["reviewer_id"], :name => "index_reviews_on_reviewer_id"
  add_index "reviews", ["session_id"], :name => "index_reviews_on_session_id"

  create_table "rooms", :force => true do |t|
    t.string   "name"
    t.integer  "capacity"
    t.integer  "conference_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "rooms", ["conference_id"], :name => "index_rooms_on_conference_id"

  create_table "session_types", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.integer  "conference_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "valid_durations"
  end

  add_index "session_types", ["conference_id"], :name => "index_session_types_on_conference_id"

  create_table "sessions", :force => true do |t|
    t.string   "title"
    t.text     "summary"
    t.text     "description"
    t.text     "mechanics"
    t.text     "benefits"
    t.string   "target_audience"
    t.integer  "audience_limit",      :limit => 255
    t.integer  "author_id"
    t.text     "experience"
    t.integer  "track_id"
    t.integer  "session_type_id"
    t.integer  "duration_mins"
    t.integer  "audience_level_id"
    t.integer  "second_author_id"
    t.string   "state"
    t.integer  "final_reviews_count",                :default => 0
    t.boolean  "author_agreement"
    t.boolean  "image_agreement"
    t.integer  "conference_id"
    t.integer  "early_reviews_count",                :default => 0
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.string   "language"
    t.integer  "comments_count",                     :default => 0
  end

  add_index "sessions", ["audience_level_id"], :name => "index_sessions_on_audience_level_id"
  add_index "sessions", ["author_id"], :name => "index_sessions_on_author_id"
  add_index "sessions", ["conference_id"], :name => "index_sessions_on_conference_id"
  add_index "sessions", ["second_author_id"], :name => "index_sessions_on_second_author_id"
  add_index "sessions", ["session_type_id"], :name => "index_sessions_on_session_type_id"
  add_index "sessions", ["track_id"], :name => "index_sessions_on_track_id"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "tracks", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "conference_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "tracks", ["conference_id"], :name => "index_tracks_on_conference_id"

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "encrypted_password"
    t.string   "password_salt"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.string   "state"
    t.string   "city"
    t.string   "organization"
    t.string   "website_url"
    t.text     "bio"
    t.integer  "roles_mask"
    t.string   "country"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "default_locale",         :default => "pt"
    t.string   "reset_password_token"
    t.string   "authentication_token"
    t.integer  "sign_in_count"
    t.datetime "reset_password_sent_at"
    t.string   "twitter_username"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  create_table "votes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "session_id"
    t.integer  "conference_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "votes", ["conference_id"], :name => "index_votes_on_conference_id"
  add_index "votes", ["session_id", "user_id"], :name => "index_votes_on_session_id_and_user_id"
  add_index "votes", ["session_id"], :name => "index_votes_on_session_id"
  add_index "votes", ["user_id"], :name => "index_votes_on_user_id"

end
