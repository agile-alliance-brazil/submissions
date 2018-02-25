# frozen_string_literal: true

module Api
  module V1
    class TagsController < ::ApplicationController
      skip_before_action :authenticate_user!, :authorize_action

      rescue_from ActiveRecord::RecordNotFound do |_exception|
        render json: { error: 'not-found' }, status: 404
      end

      def index
        tags = Session.for_conference(@conference).active.map { |s| s.keywords.map { |k| I18n.t(k) } }.flatten
        counts = tags.each_with_object({}) do |tag, acc|
          acc[tag] ||= 0
          acc[tag] += 1
        end
        hashes = counts.map do |tag, count|
          { text: tag, weight: count }
        end

        respond_to do |format|
          format.json { render json: hashes }
          format.js { render json: hashes, callback: params[:callback] }
        end
      end
    end
  end
end
