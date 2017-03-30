# encoding: UTF-8
# frozen_string_literal: true

class PublicErrorsController < ApplicationController
  skip_before_action :authenticate_user!, :authorize_action

  def unprocessable_entity
    render action: 'internal_server_error'
  end

  def conflict
    render action: 'internal_server_error'
  end

  def method_not_allowed
    render action: 'internal_server_error'
  end

  def not_implemented
    render action: 'internal_server_error'
  end
end
