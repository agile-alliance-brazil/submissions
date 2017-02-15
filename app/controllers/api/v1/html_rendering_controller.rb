# encoding: UTF-8
# frozen_string_literal: true
module Api
  module V1
    class HtmlRenderingController < ::ApplicationController
      skip_before_action :authenticate_user!, :authorize_action, :set_conference
      skip_before_action :verify_authenticity_token

      def textilize
        content = request.raw_post
        textilized = ::RedCloth.new(content, [:filter_html, :sanitize_html]).to_html(:textile).html_safe
        render html: textilized, content_type: 'text/html; charset=UTF-8'
      end
    end
  end
end
