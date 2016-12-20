# frozen_string_literal: true
class CacheCommentsCount < ActiveRecord::Migration
  def up
    execute "update sessions set comments_count=(select count(*) from comments where commentable_id=sessions.id and commentable_type='Session')"
  end

  def down; end
end
