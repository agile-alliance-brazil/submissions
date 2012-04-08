class CreateEarlyAndFinalReview < ActiveRecord::Migration
  class Review < ActiveRecord::Base
  end

  def up
    add_column :reviews, :type, :string
    Review.update_all(:type => "FinalReview")
  end

  def down
    remove_column :reviews, :type
  end
end
