class CreateRecommendation < ActiveRecord::Migration
  def self.up
    create_table :recommendations do |t|
      t.string :title

      t.timestamps
    end
  end

  def self.down
    drop_table :recommendations
  end
end
