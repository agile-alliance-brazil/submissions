# encoding: UTF-8
class SessionFilter
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :user_id, :track_id, :tags

  def initialize(params={})
    @user_id = params[:user_id]
    if params[:session_filter]
      self.username = params[:session_filter][:username]
      @tags = params[:session_filter][:tags]
      @track_id = params[:session_filter][:track_id]
    end
  end

  def username
    User.find(@user_id).username if @user_id
  end

  def username=(username)
    return if username.blank?
    @user_id = User.find_by_username(username.strip).try(:id)
  end

  def apply(scope)
    scope = scope.for_user(@user_id) if @user_id.present?
    scope = scope.tagged_with(@tags) if @tags.present?
    scope = scope.for_tracks(@track_id) if @track_id.present?
    scope
  end

  def persisted?
    false
  end
end