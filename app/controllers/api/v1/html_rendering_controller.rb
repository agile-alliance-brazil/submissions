# encoding: UTF-8
module Api
  module V1
    class HtmlRenderingController < ::ApplicationController
      skip_before_filter :authenticate_user!, :authorize_action, :set_conference
      skip_before_action :verify_authenticity_token

      def textilize
        content = request.raw_post
        puts "Raw post: #{content.inspect}"
        textilized = ::RedCloth.new(content, [:filter_html, :sanitize_html]).to_html(:textile).html_safe
        puts "Textilized version: #{textilized.inspect}"
        render html: textilized, content_type: 'text/html; charset=UTF-8'
      end
    end
  end
end
