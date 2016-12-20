# encoding: UTF-8
# frozen_string_literal: true
class UsersController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :authorize_action, only: %i(me)

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

  def me
    if current_user
      redirect_to user_path(current_user)
    else
      flash[:notice] = t('flash.no_user')
      redirect_to new_user_session_path
    end
  end

  private

  def resource
    User.where(id: params[:id]).includes(sessions: [
                                           audience_level: [:translated_contents],
                                           track: [:translated_contents],
                                           session_type: [:translated_contents]
                                         ]).first
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
      proposals: proposals_for(user)
    }
  end

  def proposals_for(user)
    user.sessions.map do |s|
      {
        session_id: s.id,
        session_uri: session_url(s.conference, s),
        name: s.title,
        status: status_for(s)
      }
    end
  end

  def status_for(s)
    if s.conference.author_confirmation < Time.zone.now
      I18n.t("session.state.#{s.state}")
    else
      I18n.t('session.state.created')
    end
  end
end
