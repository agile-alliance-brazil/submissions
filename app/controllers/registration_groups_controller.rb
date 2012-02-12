# encoding: UTF-8
class RegistrationGroupsController < InheritedResources::Base
  skip_before_filter :authenticate_user!
  actions :new, :create

  def new
    flash.now[:news] = t('flash.registration_group.news').html_safe
    new!
  end
  
  def index
    redirect_to new_registration_group_path
  end
  
  def create
    create! do |success, failure|
      success.html do
        flash[:notice] = t('flash.registration_group.create.success', :total_attendees => @registration_group.total_attendees, :attendee_url => new_registration_group_attendee_url(@registration_group)).html_safe
        redirect_to new_registration_group_attendee_path(@registration_group)
      end
      failure.html do
        flash.now[:error] = t('flash.failure')
        render :new
      end
    end
  end
end
