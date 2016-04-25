# encoding: UTF-8
module Api
  module V1
    class SessionsController < ::ApplicationController
      skip_before_action :authenticate_user!, :authorize_action
      skip_before_action :set_conference, only: [:show]

      rescue_from ActiveRecord::RecordNotFound do |exception|
        render json: { error: 'not-found' }, status: 404
      end

      def index
        sessions = Session.for_conference(@conference)
        hashes = sessions.map { |s| hash_for(s) }

        respond_to do |format|
          format.json { render json: hashes }
          format.js { render json: hashes, callback: params[:callback] }
        end
      end

      def accepted
        sessions = []
        if @conference.author_confirmation < DateTime.now
          sessions = Session.for_conference(@conference).where(state: :accepted)
        end
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
          session_uri: session_url(session.conference, session),
          title: session.title,
          authors: session.authors.map do |author|
            {
              user_id: author.id,
              user_uri: user_url(author),
              username: author.username,
              name: author.full_name,
              gravatar_url: gravatar_url(author)
            }
          end,
          prerequisites: session.prerequisites,
          tags: session.keywords.map(&:name).sort.map do |n|
            value = I18n.t(n, default: n)
            value.is_a?(String) ? value : n
          end,
          duration_mins: session.duration_mins,
          session_type: session.session_type.title,
          audience_level: session.audience_level.title,
          track: session.track.title,
          audience_limit: session.audience_limit,
          summary: session.summary,
          mechanics: session.mechanics,
          status: (session.conference.author_confirmation < DateTime.now) ? I18n.t("session.state.#{session.state}") : I18n.t('session.state.created'),
          author_agreement: session.author_agreement,
          image_agreement: session.image_agreement
        }
      end
    end
  end
end
