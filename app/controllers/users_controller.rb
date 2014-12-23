# encoding: UTF-8
class UsersController < ApplicationController
  skip_before_filter :authenticate_user!

  def show
    @user_profile = resource
  end

  def index
    collection = User.search(params[:term]).select(:username).map(&:username)
    respond_to do |format|
      format.json { render json: collection }
    end
  end

  private
  def resource
    User.find(params[:id])
  end

  def resource_class
    User
  end
end
