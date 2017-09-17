# frozen_string_literal: true

module Api
  module V1
    class UsersController < ::ApplicationController
      skip_before_action :authenticate_user!, :authorize_action, :set_conference

      before_action :doorkeeper_authorize!

      def show
        json_user = current_user.as_json(only: %i[
                                           id email username first_name last_name twitter_username
                                           organization phone country state city default_locale
                                         ],
                                         methods: %i[reviewer? organizer?])
        render json: json_user
      end

      def make_voter
        current_user.add_role :voter
        current_user.save
        render json: { success: true, vote_url: sessions_url }
      end

      private

      def current_user
        @current_user ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
      end
    end
  end
end
