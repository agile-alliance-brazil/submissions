class AttendeesController < InheritedResources::Base
  skip_before_filter :authenticate_user!
  actions :new, :create

  def index
    redirect_to new_attendee_path
  end
  
  def new
    flash.now[:news] = t('flash.attendee.news').html_safe
    new!
  end
  
  def create
    create! do |success, failure|
      success.html do
        begin
          EmailNotifications.registration_pending(@attendee).deliver
          @attendee.email_sent=true
          @attendee.save
        rescue e
          flash[:alert] = t('flash.attendee.mail.fail')
        end
        flash[:notice] = t('flash.attendee.create.success')
        redirect_to root_path
      end
      failure.html do
        flash.now[:error] = t('flash.failure')
        render :new
      end
    end
  end
  
  def pre_registered
    email = params[:email]
    pre_registration = PreRegistration.registered(email).first
    pre_registered = (not pre_registration.nil?) && (not pre_registration.used?)
    respond_to do |format|
      format.js { render :js => pre_registered.to_s }
    end
  end
  
  private
  def build_resource
    attributes = params[:attendee] || {}
    attributes[:conference_id] = current_conference.id
    @attendee ||= end_of_association_chain.send(method_for_build, attributes)
  end
end