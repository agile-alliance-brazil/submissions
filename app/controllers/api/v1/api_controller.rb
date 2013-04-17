# encoding: UTF-8
module Api
  module V1
    class ApiController < ::ApplicationController
      skip_before_filter :authenticate_user!, :authorize_action, :set_conference

      doorkeeper_for :all
      respond_to :json

      private
      def current_user
        @current_user ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
      end
    end
  end
end