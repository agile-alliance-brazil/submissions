class PasswordResetsController < ApplicationController
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]
  before_filter :logout_required

  def index
    render :new
  end
  
  def new
  end
  
  def create
    @user = User.find_by_email(params[:user][:email])
    if @user
      @user.deliver_password_reset_instructions!
      flash[:notice] = t('flash.password_reset.create.success')
      redirect_to root_url
    else
      flash.now[:error] = t('flash.password_reset.create.failure')
      render :new
    end
  end
  
  def edit
  end

  def update
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if params[:user][:password].blank?
      flash.now[:error] = t('flash.password_reset.update.failure')
      render :edit
    else
      if @user.save
        flash[:notice] = t('flash.password_reset.update.success')
        UserSession.create(@user)
        redirect_to root_url
      else
        flash.now[:error] = t('flash.failure')
        render :edit
      end
    end
  end

  private
  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    unless @user
      flash[:notice] = t('flash.password_reset.invalid_token')
      redirect_to root_url
      return false
    end
  end
end
