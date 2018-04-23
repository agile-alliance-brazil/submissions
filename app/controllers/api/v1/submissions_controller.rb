module Api
  module V1
    class SubmissionsController < ::ApplicationController
      skip_before_action :authenticate_user!, :authorize_action
      skip_before_action :set_conference

      rescue_from ActiveRecord::RecordNotFound do |_exception|
        render json: { error: 'not-found' }, status: :not_found
      end

      def index
        conferences = Conference.all
        length = conferences.map{|c| (c.submissions_deadline.to_date - c.submissions_open.to_date).to_i }.max

        conf_distribution = conferences.map do |c|
          conference_length = (c.submissions_deadline.to_date - c.submissions_open.to_date).to_i
          buckets = Array.new(length + 1, 0)
          counts = Session.for_conference(c).active.inject(buckets) do |acc, s|
            creation_percent = (s.created_at.to_date - c.submissions_open.to_date).to_i.to_f / conference_length
            creation_bucket = [0, [(creation_percent * length).to_i, length].min].max
            acc[creation_bucket] = 0 unless acc[creation_bucket]
            acc[creation_bucket]+= 1
            acc
          end

          accumulated = counts.each_with_index.inject(Array.new(length + 1, 0)) do |acc, (count, index)|
            acc[index] = count
            acc[index] += acc[index-1] if index > 0
            acc
          end

          {
            year: c.year,
            creation_distribution: counts,
            accumulated_distribution: accumulated
          }
        end

        respond_to do |format|
          format.json { render json: conf_distribution }
          format.js { render json: conf_distribution, callback: params[:callback] }
        end
      end
    end
  end
end