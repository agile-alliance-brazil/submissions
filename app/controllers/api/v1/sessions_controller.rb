# encoding: UTF-8
module Api
  module V1
    class SessionsController < ::ApplicationController
      skip_before_filter :authenticate_user!, :authorize_action, :set_conference

      respond_to :json

      def show
        session = Session.find(params[:id])
        respond_with({
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
          summary: session.summary
        })
      end
    end
  end
end
