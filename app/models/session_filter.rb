# frozen_string_literal: true

class SessionFilter
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :conference, :user_id, :track_id, :session_type_id, :audience_level_id, :tags, :state

  def initialize(filter = nil, user_id = nil)
    @user_id = user_id
    return unless filter

    @conference = filter[:conference]
    self.username = filter[:username]
    @tags = filter[:tags]
    @state = filter[:state]
    @track_id = filter[:track_id]
    @session_type_id = filter[:session_type_id]
    @audience_level_id = filter[:audience_level_id]
  end

  def username
    User.find(@user_id).username if @user_id
  end

  def username=(username)
    return if username.blank?

    @user_id = User.find_by(username: username.strip).try(:id)
  end

  def apply(scope)
    scope = scope.for_user(@user_id) if @user_id.present?
    scope = scope.tagged_with(to_tag_keys(@tags)) if @tags.present?
    scope = scope.with_state(@state.to_sym) if @state.present?
    scope = scope.for_tracks(@track_id) if @track_id.present?
    scope = scope.for_audience_level(@audience_level_id) if @audience_level_id.present?
    scope = scope.for_session_type(@session_type_id) if @session_type_id.present?
    scope
  end

  def persisted?
    false
  end

  private

  def to_tag_keys(tag_list)
    return nil if tag_list.blank?

    tag_names = tag_list.split(/\s*,\s*/)
    return nil if tag_names.empty?

    conference_tags = (@conference.try(:tags) || [])
    return tag_names.join(', ') if conference_tags.empty?

    tags = conference_tags.select do |tag|
      if I18n.exists?(tag.name, I18n.locale)
        tag_names.include?(I18n.t(tag.name))
      else
        tag_names.include?(tag.name)
      end
    end

    return nil if tags.empty?

    tags.map(&:name).join(', ')
  end
end
