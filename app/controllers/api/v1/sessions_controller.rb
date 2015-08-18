# encoding: UTF-8
module Api
  module V1
    class SessionsController < ::ApplicationController
      skip_before_action :authenticate_user!, :authorize_action
      skip_before_action :set_conference, only: [:show]

      rescue_from ActiveRecord::RecordNotFound do |exception|
        render json: {error: "not-found"}.to_json, status: 404
      end

      def accepted
        sessions = Session.for_conference(@conference).where(state: :accepted)
        hashes = sessions.map { |s| hash_for(s) }

        respond_to do |format|
          format.json { render json: hashes }
          format.js { render json: hashes, callback: params[:callback] }
        end
      end

      def show
        session = Session.find(params[:id])

        session_hash = hash_for(session)

        respond_to do |format|
          format.json { render json: session_hash }
          format.js { render json: session_hash, callback: params[:callback]}
        end
      end

      private

      def hash_for(session)
        {
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
      end
    end
  end
end
