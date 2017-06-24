# encoding: UTF-8
# frozen_string_literal: true

module Api
  module V1
    class SessionsController < ::ApplicationController
      skip_before_action :authenticate_user!, :authorize_action
      skip_before_action :set_conference, only: [:show]

      rescue_from ActiveRecord::RecordNotFound do |_exception|
        render json: { error: 'not-found' }, status: 404
      end

      def index
        sessions = Session.for_conference(@conference).includes(
          :conference, :author, :second_author, :review_decision,
          session_type: [:translated_contents],
          track: [:translated_contents],
          audience_level: [:translated_contents]
        )
        hashes = sessions.map { |s| hash_for(s) }

        respond_to do |format|
          format.json { render json: hashes }
          format.js { render json: hashes, callback: params[:callback] }
        end
      end

      def accepted
        sessions = Session.for_conference(@conference).includes(
          :conference, :author, :second_author, :review_decision,
          session_type: [:translated_contents],
          track: [:translated_contents],
          audience_level: [:translated_contents]
        ).where(state: [:pending_confirmation, :accepted], review_decisions: { published: true })
        hashes = sessions.map { |s| hash_for(s) }

        respond_to do |format|
          format.json { render json: hashes }
          format.js { render json: hashes, callback: params[:callback] }
        end
      end

      def show
        session = Session.includes(
          :conference, :author, :second_author, :review_decision,
          session_type: [:translated_contents],
          track: [:translated_contents],
          audience_level: [:translated_contents]
        ).find(params[:id])

        session_hash = hash_for(session)

        respond_to do |format|
          format.json { render json: session_hash }
          format.js { render json: session_hash, callback: params[:callback] }
        end
      end

      private

      def hash_for(session)
        {
          id: session.id,
          session_uri: session_url(session.conference, session),
          title: session.title,
          authors: authors_for(session),
          prerequisites: session.prerequisites,
          tags: tags_for(session),
          duration_mins: session.duration_mins,
          session_type: session.session_type.title,
          audience_level: session.audience_level.title,
          track: session.track.title,
          audience_limit: session.audience_limit,
          summary: session.summary,
          mechanics: session.mechanics,
          status: status_for(session),
          author_agreement: session.author_agreement,
          image_agreement: session.image_agreement,
          created_at: session.created_at.iso8601
        }
      end

      def authors_for(session)
        session.authors.map do |author|
          {
            user_id: author.id,
            user_uri: user_url(author),
            username: author.username,
            name: author.full_name,
            gravatar_url: gravatar_url(author),
            default_locale: author.default_locale
          }
        end
      end

      def tags_for(session)
        session.keywords.map(&:name).sort.map do |n|
          value = I18n.t(n, default: n)
          value.is_a?(String) ? value : n
        end
      end

      def status_for(session)
        if session.review_decision.try(:published?)
          I18n.t("session.state.#{session.state}")
        else
          I18n.t('session.state.created')
        end
      end
    end
  end
end
