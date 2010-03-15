class CreateReviewers < ActiveRecord::Migration
  def self.up
    create_table :reviewers do |t|
      t.references :user
      t.string :state

      t.timestamps
    end
  end

  def self.down
    drop_table :reviewers
  end
end
