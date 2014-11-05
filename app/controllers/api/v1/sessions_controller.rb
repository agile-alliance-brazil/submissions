# encoding: UTF-8
module Api
  module V1
    class SessionsController < ::ApplicationController
      skip_before_filter :authenticate_user!, :authorize_action, :set_conference

      respond_to :json, :js

      rescue_from ActiveRecord::RecordNotFound do |exception|
        render json: {error: "not-found"}.to_json, status: 404
      end

      def show
        session = Session.find(params[:id])

        session_hash = {
          id: session.id,
          title: session.title,
          authors: session.authors.map do |author|
            {
              name: author.full_name,
              gravatar_url: gravatar_url(author)
            }
          end,
          prerequisites: session.prerequisites,
          tags: session.keywords.map(&:name).sort.map do |n|
            value = I18n.t(n, default: n)
            value.is_a?(String) ? value : n
          end,
          session_type: I18n.t(session.session_type.title),
          audience_level: I18n.t(session.audience_level.title),
          track: I18n.t(session.track.title),
          audience_limit: session.audience_limit,
          summary: session.summary
        }

        respond_with do |format|
          format.json { render json: session_hash }
          format.js { render json: session_hash, callback: params[:callback]}
        end
      end
    end
  end
end
