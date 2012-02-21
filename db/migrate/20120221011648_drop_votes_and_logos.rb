class DropVotesAndLogos < ActiveRecord::Migration
  def up
    drop_table :votes
    drop_table :logos
  end

  def down
    create_table :logos do |t|
      t.string   :format
      t.timestamps
    end
    
    create_table :votes do |t|
      t.references  :user
      t.references  :logo
      t.string      :user_ip
      t.timestamps
    end
  end
end
