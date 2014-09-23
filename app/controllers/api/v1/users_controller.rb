# encoding: UTF-8
module Api
  module V1
    class UsersController < ApiController
      def show
        respond_with current_user.as_json({
          only: [
            :id, :email, :username, :first_name, :last_name, :twitter_username,
            :organization, :phone, :country, :state, :city
          ],
          methods: [:reviewer?, :organizer?]
        })
      end

      def make_voter
        current_user.add_role :voter
        current_user.save
        render json: {success: true, vote_url: sessions_url}
      end
    end
  end
end