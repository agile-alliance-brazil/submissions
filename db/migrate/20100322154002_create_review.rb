class CreateReview < ActiveRecord::Migration
  def self.up
    create_table :reviews do |t|
      t.references :author_agile_xp_rating
      t.references :author_proposal_xp_rating
      
      t.boolean :proposal_track
      t.boolean :proposal_level
      t.boolean :proposal_type
      t.boolean :proposal_duration
      t.boolean :proposal_limit
      t.boolean :proposal_abstract
      
      t.references :proposal_quality_rating
      t.references :proposal_relevance_rating

      t.references :recommendation
      t.text :justification
      
      t.references :reviewer_confidence_rating
      
      t.text :comments_to_organizers
      t.text :comments_to_authors

      t.references :reviewer
      t.references :session
      
      t.timestamps
    end
  end

  def self.down
    drop_table :reviews
  end
end
