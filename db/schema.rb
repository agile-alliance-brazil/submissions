# encoding: UTF-8
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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20200322142728) do

  create_table "all_hands", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "audience_levels", force: :cascade do |t|
    t.string   "title",         limit: 255
    t.string   "description",   limit: 255
    t.integer  "conference_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "audience_levels", ["conference_id"], name: "index_audience_levels_on_conference_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.text     "comment",          limit: 65535
    t.integer  "commentable_id",   limit: 4
    t.string   "commentable_type", limit: 255
    t.integer  "user_id",          limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["commentable_type"], name: "index_comments_on_commentable_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "conferences", force: :cascade do |t|
    t.string   "name",                         limit: 255
    t.integer  "year",                         limit: 4
    t.datetime "call_for_papers"
    t.datetime "submissions_open"
    t.datetime "submissions_deadline"
    t.datetime "review_deadline"
    t.datetime "author_notification"
    t.datetime "author_confirmation"
    t.string   "location_and_date",            limit: 255
    t.datetime "presubmissions_deadline"
    t.datetime "prereview_deadline"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "voting_deadline"
    t.boolean  "visible",                                  default: false
    t.string   "location",                     limit: 255
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "logo_file_name",               limit: 255
    t.string   "logo_content_type",            limit: 255
    t.integer  "logo_file_size",               limit: 8
    t.datetime "logo_updated_at"
    t.string   "supported_languages",          limit: 255, default: "en,pt-BR", null: false
    t.boolean  "allow_free_form_tags",                     default: true,       null: false
    t.integer  "submission_limit",             limit: 4,   default: 0,          null: false
    t.integer  "tag_limit",                    limit: 4,   default: 0,          null: false
    t.datetime "submissions_edition_deadline"
  end

  add_index "conferences", ["year"], name: "index_conferences_on_year", unique: true, using: :btree

  create_table "guest_sessions", force: :cascade do |t|
    t.string   "title",         limit: 255
    t.string   "author",        limit: 255
    t.text     "summary",       limit: 65535
    t.integer  "conference_id", limit: 4
    t.boolean  "keynote",                     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "guest_sessions", ["conference_id"], name: "index_guest_sessions_on_conference_id", using: :btree

  create_table "lightning_talk_groups", force: :cascade do |t|
    t.string   "lightning_talk_info", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", limit: 4,   null: false
    t.integer  "application_id",    limit: 4,   null: false
    t.string   "token",             limit: 255, null: false
    t.integer  "expires_in",        limit: 4,   null: false
    t.string   "redirect_uri",      limit: 255, null: false
    t.datetime "created_at",                    null: false
    t.datetime "revoked_at"
    t.string   "scopes",            limit: 255
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id", limit: 4
    t.integer  "application_id",    limit: 4,   null: false
    t.string   "token",             limit: 255, null: false
    t.string   "refresh_token",     limit: 255
    t.integer  "expires_in",        limit: 4
    t.datetime "revoked_at"
    t.datetime "created_at",                    null: false
    t.string   "scopes",            limit: 255
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",         limit: 255,                null: false
    t.string   "uid",          limit: 255,                null: false
    t.string   "secret",       limit: 255,                null: false
    t.string   "redirect_uri", limit: 255,                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "scopes",       limit: 255, default: "",   null: false
    t.boolean  "confidential",             default: true, null: false
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "organizers", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.integer  "track_id",      limit: 4
    t.integer  "conference_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organizers", ["conference_id"], name: "index_organizers_on_conference_id", using: :btree
  add_index "organizers", ["track_id", "user_id"], name: "index_organizers_on_track_id_and_user_id", using: :btree
  add_index "organizers", ["track_id"], name: "index_organizers_on_track_id", using: :btree
  add_index "organizers", ["user_id"], name: "index_organizers_on_user_id", using: :btree

  create_table "outcomes", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pages", force: :cascade do |t|
    t.integer  "conference_id", limit: 4
    t.string   "path",          limit: 255,                   null: false
    t.string   "content",       limit: 255, default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "language",      limit: 255, default: "pt-BR", null: false
    t.string   "title",         limit: 255, default: "",      null: false
    t.boolean  "show_in_menu",              default: false,   null: false
  end

  create_table "preferences", force: :cascade do |t|
    t.integer  "reviewer_id",       limit: 4
    t.integer  "track_id",          limit: 4
    t.integer  "audience_level_id", limit: 4
    t.boolean  "accepted",                    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "preferences", ["audience_level_id"], name: "index_preferences_on_audience_level_id", using: :btree
  add_index "preferences", ["reviewer_id"], name: "index_preferences_on_reviewer_id", using: :btree
  add_index "preferences", ["track_id"], name: "index_preferences_on_track_id", using: :btree

  create_table "ratings", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recommendations", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "review_decisions", force: :cascade do |t|
    t.integer  "session_id",      limit: 4
    t.integer  "outcome_id",      limit: 4
    t.integer  "organizer_id",    limit: 4
    t.text     "note_to_authors", limit: 65535
    t.boolean  "published",                     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "review_decisions", ["organizer_id"], name: "index_review_decisions_on_organizer_id", using: :btree
  add_index "review_decisions", ["outcome_id"], name: "index_review_decisions_on_outcome_id", using: :btree
  add_index "review_decisions", ["session_id"], name: "index_review_decisions_on_session_id", using: :btree

  create_table "review_evaluations", force: :cascade do |t|
    t.integer  "review_id",          limit: 4
    t.integer  "review_feedback_id", limit: 4
    t.boolean  "helpful_review"
    t.text     "comments",           limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "review_feedbacks", force: :cascade do |t|
    t.integer  "conference_id",    limit: 4
    t.integer  "author_id",        limit: 4
    t.text     "general_comments", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reviewers", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.integer  "conference_id", limit: 4
    t.string   "state",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "sign_reviews"
  end

  add_index "reviewers", ["conference_id"], name: "index_reviewers_on_conference_id", using: :btree
  add_index "reviewers", ["user_id"], name: "index_reviewers_on_user_id", using: :btree

  create_table "reviews", force: :cascade do |t|
    t.integer  "author_agile_xp_rating_id",     limit: 4
    t.integer  "author_proposal_xp_rating_id",  limit: 4
    t.boolean  "proposal_track"
    t.boolean  "proposal_level"
    t.boolean  "proposal_type"
    t.boolean  "proposal_duration"
    t.boolean  "proposal_limit"
    t.boolean  "proposal_abstract"
    t.integer  "proposal_quality_rating_id",    limit: 4
    t.integer  "proposal_relevance_rating_id",  limit: 4
    t.integer  "recommendation_id",             limit: 4
    t.text     "justification",                 limit: 65535
    t.integer  "reviewer_confidence_rating_id", limit: 4
    t.text     "comments_to_organizers",        limit: 65535
    t.text     "comments_to_authors",           limit: 65535
    t.integer  "reviewer_id",                   limit: 4
    t.integer  "session_id",                    limit: 4
    t.string   "type",                          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reviews", ["author_agile_xp_rating_id"], name: "index_reviews_on_author_agile_xp_rating_id", using: :btree
  add_index "reviews", ["author_proposal_xp_rating_id"], name: "index_reviews_on_author_proposal_xp_rating_id", using: :btree
  add_index "reviews", ["id", "type"], name: "index_reviews_on_id_and_type", using: :btree
  add_index "reviews", ["proposal_quality_rating_id"], name: "index_reviews_on_proposal_quality_rating_id", using: :btree
  add_index "reviews", ["proposal_relevance_rating_id"], name: "index_reviews_on_proposal_relevance_rating_id", using: :btree
  add_index "reviews", ["recommendation_id"], name: "index_reviews_on_recommendation_id", using: :btree
  add_index "reviews", ["reviewer_confidence_rating_id"], name: "index_reviews_on_reviewer_confidence_rating_id", using: :btree
  add_index "reviews", ["reviewer_id"], name: "index_reviews_on_reviewer_id", using: :btree
  add_index "reviews", ["session_id"], name: "index_reviews_on_session_id", using: :btree

  create_table "rooms", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "capacity",      limit: 4
    t.integer  "conference_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rooms", ["conference_id"], name: "index_rooms_on_conference_id", using: :btree

  create_table "session_types", force: :cascade do |t|
    t.string   "title",                limit: 255
    t.string   "description",          limit: 255
    t.integer  "conference_id",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "valid_durations",      limit: 255
    t.boolean  "needs_audience_limit",             default: false, null: false
    t.boolean  "needs_mechanics",                  default: false, null: false
  end

  add_index "session_types", ["conference_id"], name: "index_session_types_on_conference_id", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "title",                      limit: 255
    t.text     "summary",                    limit: 65535
    t.text     "description",                limit: 65535
    t.text     "mechanics",                  limit: 65535
    t.text     "benefits",                   limit: 65535
    t.string   "target_audience",            limit: 255
    t.integer  "audience_limit",             limit: 2
    t.integer  "author_id",                  limit: 4
    t.text     "experience",                 limit: 65535
    t.integer  "track_id",                   limit: 4
    t.integer  "session_type_id",            limit: 4
    t.integer  "duration_mins",              limit: 4
    t.integer  "audience_level_id",          limit: 4
    t.integer  "second_author_id",           limit: 4
    t.string   "state",                      limit: 255
    t.integer  "final_reviews_count",        limit: 4,     default: 0
    t.boolean  "author_agreement"
    t.boolean  "image_agreement"
    t.integer  "conference_id",              limit: 4
    t.integer  "early_reviews_count",        limit: 4,     default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "language",                   limit: 255
    t.integer  "comments_count",             limit: 4,     default: 0
    t.string   "prerequisites",              limit: 255
    t.string   "video_link",                 limit: 255
    t.text     "additional_links",           limit: 65535
    t.boolean  "first_presentation",                       default: false, null: false
    t.text     "presentation_justification", limit: 65535
  end

  add_index "sessions", ["audience_level_id"], name: "index_sessions_on_audience_level_id", using: :btree
  add_index "sessions", ["author_id"], name: "index_sessions_on_author_id", using: :btree
  add_index "sessions", ["conference_id"], name: "index_sessions_on_conference_id", using: :btree
  add_index "sessions", ["second_author_id"], name: "index_sessions_on_second_author_id", using: :btree
  add_index "sessions", ["session_type_id"], name: "index_sessions_on_session_type_id", using: :btree
  add_index "sessions", ["track_id"], name: "index_sessions_on_track_id", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        limit: 4
    t.integer  "taggable_id",   limit: 4
    t.string   "taggable_type", limit: 255
    t.integer  "tagger_id",     limit: 4
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["context"], name: "index_taggings_on_context", using: :btree
  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy", using: :btree
  add_index "taggings", ["taggable_id"], name: "index_taggings_on_taggable_id", using: :btree
  add_index "taggings", ["taggable_type"], name: "index_taggings_on_taggable_type", using: :btree
  add_index "taggings", ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type", using: :btree
  add_index "taggings", ["tagger_id"], name: "index_taggings_on_tagger_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "expiration_year", limit: 4
    t.integer  "taggings_count",  limit: 4,   default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "tracks", force: :cascade do |t|
    t.string   "title",         limit: 255
    t.text     "description",   limit: 65535
    t.integer  "conference_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tracks", ["conference_id"], name: "index_tracks_on_conference_id", using: :btree

  create_table "translated_contents", force: :cascade do |t|
    t.integer  "model_id",    limit: 4
    t.string   "model_type",  limit: 255
    t.string   "title",       limit: 255,                null: false
    t.string   "description", limit: 255,   default: "", null: false
    t.string   "language",    limit: 255,                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "content",     limit: 65535
  end

  create_table "users", force: :cascade do |t|
    t.string   "username",               limit: 255
    t.string   "email",                  limit: 255
    t.string   "encrypted_password",     limit: 255
    t.string   "password_salt",          limit: 255
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.string   "phone",                  limit: 255
    t.string   "state",                  limit: 255
    t.string   "city",                   limit: 255
    t.string   "organization",           limit: 255
    t.string   "website_url",            limit: 255
    t.text     "bio",                    limit: 65535
    t.integer  "roles_mask",             limit: 4
    t.string   "country",                limit: 255
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "default_locale",         limit: 255,   default: "pt-BR"
    t.string   "reset_password_token",   limit: 255
    t.string   "authentication_token",   limit: 255
    t.integer  "sign_in_count",          limit: 4
    t.datetime "reset_password_sent_at"
    t.string   "twitter_username",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "votes", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.integer  "session_id",    limit: 4
    t.integer  "conference_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["conference_id"], name: "index_votes_on_conference_id", using: :btree
  add_index "votes", ["session_id", "user_id"], name: "index_votes_on_session_id_and_user_id", using: :btree
  add_index "votes", ["session_id"], name: "index_votes_on_session_id", using: :btree
  add_index "votes", ["user_id"], name: "index_votes_on_user_id", using: :btree

end
