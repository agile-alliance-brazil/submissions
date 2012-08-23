# encoding: UTF-8
class CreateLightningTalkGroups < ActiveRecord::Migration
  def change
    create_table :lightning_talk_groups do |t|
      t.string :lightning_talk_info
      t.timestamps
    end
  end
end
