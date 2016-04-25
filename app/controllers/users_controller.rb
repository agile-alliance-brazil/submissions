# encoding: UTF-8
class UsersController < ApplicationController
  skip_before_filter :authenticate_user!

  def show
    @user_profile = resource
    respond_to do |format|
      format.json { render json: public_hash(@user_profile) }
      format.html
    end
  end

  def index
    collection = User.search(params[:term]).select(:username).map(&:username)
    respond_to do |format|
      format.json { render json: collection }
    end
  end

  private
  def resource
    User.where(id: params[:id]).includes(sessions: [
      audience_level: [:translated_contents],
      track: [:translated_contents],
      session_type: [:translated_contents]]).first
  end

  def resource_class
    User
  end

  def public_hash(user)
    {
      user_id: user.id,
      user_uri: user_url(user),
      username: user.username,
      name: user.full_name,
      gravatar_url: gravatar_url(user),
      organization: user.organization,
      website_url: user.website_url,
      bio: user.bio,
      proposals: user.sessions.map do |s|
        {
          session_id: s.id,
          session_uri: session_url(s.conference, s),
          name: s.title,
          status: (s.conference.author_confirmation < DateTime.now) ? I18n.t("session.state.#{s.state}") : I18n.t('session.state.created')
        }
      end
    }
  end
end
