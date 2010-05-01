# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100501033554) do

  create_table "audience_levels", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.text     "comment",          :default => ""
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "logos", :force => true do |t|
    t.string   "format"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organizers", :force => true do |t|
    t.integer  "user_id"
    t.integer  "track_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "outcomes", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "preferences", :force => true do |t|
    t.integer  "reviewer_id"
    t.integer  "track_id"
    t.integer  "audience_level_id"
    t.boolean  "accepted",          :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ratings", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recommendations", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "review_decisions", :force => true do |t|
    t.integer  "session_id"
    t.integer  "outcome_id"
    t.text     "note_to_authors"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organizer_id"
    t.boolean  "published",       :default => false
  end

  create_table "reviewers", :force => true do |t|
    t.integer  "user_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "session_types", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "title"
    t.text     "summary"
    t.text     "description"
    t.text     "mechanics"
    t.text     "benefits"
    t.string   "target_audience"
    t.integer  "audience_limit",    :limit => 255
    t.integer  "author_id"
    t.text     "experience"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "track_id"
    t.integer  "session_type_id"
    t.integer  "duration_mins"
    t.integer  "audience_level_id"
    t.integer  "second_author_id"
    t.string   "state"
    t.integer  "reviews_count",                    :default => 0
    t.boolean  "author_agreement"
    t.boolean  "image_agreement"
  end

  create_table "slots", :force => true do |t|
    t.integer  "session_id"
    t.integer  "track_id"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "duration_mins"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type"
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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "persistence_token"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.string   "perishable_token"
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.string   "default_locale",    :default => "pt"
  end

  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"

  create_table "votes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "logo_id"
    t.string   "user_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
