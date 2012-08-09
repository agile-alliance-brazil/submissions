# encoding: UTF-8
class AgilebrazilBaseline < ActiveRecord::Migration
  def change
    create_table :audience_levels do |t|
      t.string      :title
      t.string      :description
      t.references  :conference
      t.timestamps
    end

    create_table :comments do |t|
      t.text        :comment, :default => ""
      t.references  :commentable, :polymorphic => true
      t.references  :user
      t.timestamps
    end

    add_index :comments, :commentable_type
    add_index :comments, :commentable_id
    add_index :comments, :user_id

    create_table :conferences do |t|
      t.string      :name
      t.integer     :year
      t.datetime    :call_for_papers
      t.datetime    :submissions_open
      t.datetime    :submissions_deadline
      t.datetime    :review_deadline
      t.datetime    :author_notification
      t.datetime    :author_confirmation
      t.string      :location_and_date
      t.datetime    :presubmissions_deadline
      t.datetime    :prereview_deadline
      t.timestamps
    end

    create_table :organizers do |t|
      t.references  :user
      t.references  :track
      t.references  :conference
      t.timestamps
    end

    create_table :outcomes do |t|
      t.string      :title
      t.timestamps
    end

    create_table :preferences do |t|
      t.references  :reviewer
      t.references  :track
      t.references  :audience_level
      t.boolean     :accepted, :default => false
      t.timestamps
    end

    create_table :ratings do |t|
      t.string      :title
      t.timestamps
    end

    create_table :recommendations do |t|
      t.string      :title
      t.timestamps
    end

    create_table :review_decisions do |t|
      t.references  :session
      t.references  :outcome
      t.references  :organizer
      t.text        :note_to_authors
      t.boolean     :published, :default => false
      t.timestamps
    end

    create_table :reviewers do |t|
      t.references  :user
      t.references  :conference
      t.string      :state
      t.timestamps
    end

    create_table :reviews do |t|
      t.references  :author_agile_xp_rating
      t.references  :author_proposal_xp_rating
      t.boolean     :proposal_track
      t.boolean     :proposal_level
      t.boolean     :proposal_type
      t.boolean     :proposal_duration
      t.boolean     :proposal_limit
      t.boolean     :proposal_abstract
      t.references  :proposal_quality_rating
      t.references  :proposal_relevance_rating
      t.references  :recommendation
      t.text        :justification
      t.references  :reviewer_confidence_rating
      t.text        :comments_to_organizers
      t.text        :comments_to_authors
      t.references  :reviewer
      t.references  :session
      t.string      :type
      t.timestamps
    end

    create_table :session_types do |t|
      t.string      :title
      t.string      :description
      t.references  :conference
      t.timestamps
    end

    create_table :sessions do |t|
      t.string      :title
      t.text        :summary
      t.text        :description
      t.text        :mechanics
      t.text        :benefits
      t.string      :target_audience
      t.integer     :audience_limit, :limit => 255
      t.references  :author
      t.text        :experience
      t.references  :track
      t.references  :session_type
      t.integer     :duration_mins
      t.references  :audience_level
      t.references  :second_author
      t.string      :state
      t.integer     :final_reviews_count, :default => 0
      t.boolean     :author_agreement
      t.boolean     :image_agreement
      t.references  :conference
      t.integer     :early_reviews_count, :default => 0
      t.timestamps
    end

    create_table :taggings do |t|
      t.references  :tag
      t.references  :taggable, :polymorphic => true
      t.references  :tagger, :polymorphic => true
      t.string      :context
      t.datetime    :created_at
    end

    add_index :taggings, :tag_id
    add_index :taggings, [:taggable_id, :taggable_type, :context]

    create_table :tags do |t|
      t.string :name
    end

    create_table :tracks do |t|
      t.string      :title
      t.text        :description
      t.references  :conference
      t.timestamps
    end

    create_table :users do |t|
      t.string      :username
      t.string      :email
      t.string      :encrypted_password
      t.string      :password_salt
      t.string      :first_name
      t.string      :last_name
      t.string      :phone
      t.string      :state
      t.string      :city
      t.string      :organization
      t.string      :website_url
      t.text        :bio
      t.integer     :roles_mask
      t.string      :country
      t.datetime    :current_sign_in_at
      t.datetime    :last_sign_in_at
      t.string      :current_sign_in_ip
      t.string      :last_sign_in_ip
      t.string      :default_locale, :default => "pt"
      t.string      :reset_password_token
      t.string      :authentication_token
      t.integer     :sign_in_count
      t.datetime    :reset_password_sent_at
      t.string      :twitter_username
      t.timestamps
    end
  end
end