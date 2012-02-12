# encoding: UTF-8
class CreateReviewDecisions < ActiveRecord::Migration
  def self.up
    create_table :review_decisions do |t|
      t.references  :session
      t.references  :outcome
      t.text        :note_to_authors

      t.timestamps
    end
  end

  def self.down
    drop_table :review_decisions
  end
end
