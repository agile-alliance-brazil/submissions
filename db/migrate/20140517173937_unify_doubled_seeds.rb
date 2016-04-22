class UnifyDoubledSeeds < ActiveRecord::Migration
  def up
    seeded_tags = ActsAsTaggableOn::Tag.where('expiration_year IS NULL').all
    seeded_tags_map = seeded_tags.group_by {|tag| tag.name}
    tags_to_keep = seeded_tags_map.values.map {|tags| tags.first}
    id_map = tags_to_keep.inject({}) do |acc, keep|
      acc[keep.id] = seeded_tags.select {|tag| tag.name == keep.name && tag.id != keep.id}.map(&:id)
      acc
    end
    duplicated_ids = []
    id_map.each do |key, value|
      ActsAsTaggableOn::Tagging.where(tag_id: value).update_all(tag_id: key)
      taggings = ActsAsTaggableOn::Tagging.where(tag_id: key).all
      grouped = taggings.group_by do |tagging|
        [tagging.taggable_id, tagging.taggable_type, tagging.context]
      end
      duplicated_ids << grouped.values.map {|dup| dup[1..-1].map {|d| d.id}}
    end
    duplicated_ids
    ActsAsTaggableOn::Tagging.delete_all(id: duplicated_ids.flatten)
    ActsAsTaggableOn::Tag.delete_all(id: id_map.values.flatten)
  end

  def down
    # Can't down data drop
  end
end
