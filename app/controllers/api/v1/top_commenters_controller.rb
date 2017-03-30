# encoding: UTF-8
# frozen_string_literal: true

module Api
  module V1
    class TopCommentersController < ::ApplicationController
      skip_before_action :authenticate_user!, :authorize_action, :set_conference
      MAX_LIMIT = 20
      DEFAULT_LIMIT = 5

      def index
        commenters = User.by_comments(filters).limit(valid_limit).select do |u|
          u.comments.count.positive?
        end
        top_commenters = commenters.map do |user|
          gravatar_id = Digest::MD5.hexdigest(user.email).downcase
          picture = "https://gravatar.com/avatar/#{gravatar_id}.png"
          { user: user.username, name: user.full_name, picture: picture, comment_count: user.comments.where(filters).count }
        end
        render json: top_commenters
      end

      private

      def filters
        filters = { commentable_type: 'Session' }
        if params[:filter].try(:[], :year)
          conference_ids = Conference.where(year: params[:filter][:year]).select(:id)
          filters[:commentable_id] = Session.where(conference_id: conference_ids).select(:id)
        end
        filters
      end

      def valid_limit
        limit = params[:limit].to_i
        if limit > MAX_LIMIT
          limit = MAX_LIMIT
        elsif limit < 1
          limit = DEFAULT_LIMIT
        end
        limit
      end
    end
  end
end
