# frozen_string_literal: true

class OutcomesController < ApplicationController
  skip_before_action :authenticate_user!, :authorize_action

  def index
    outcomes = Outcome.order(:order).all.map do |outcome|
      { id: outcome.id, title: I18n.t(outcome.title), order: outcome.order }
    end
    render json: outcomes
  end
end
