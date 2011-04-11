class AttendeesController < InheritedResources::Base
  belongs_to :registration_group, :optional => true
  
  skip_before_filter :authenticate_user!
  actions :new, :create
  
  before_filter :validate_total_attendees, :only => [:new, :create]
  before_filter :load_registration_types, :only => [:new, :create]

  def index
    redirect_to new_attendee_path
  end
  
  def new
    flash.now[:news] = t('flash.attendee.news').html_safe unless parent?
    new!
  end
  
  def create
    create! do |success, failure|
      success.html do
        begin
          if parent?
            EmailNotifications.registration_group_attendee(@attendee, parent).deliver
            @attendee.email_sent = true
            @attendee.save
            if parent.complete?
              flash[:notice] = t('flash.attendee.create.success')
              EmailNotifications.registration_group_pending(parent).deliver
              parent.email_sent = true
              parent.save
              redirect_to root_path
            else
              flash[:notice] = t('flash.attendee.registration_group.success')
              redirect_to new_registration_group_attendee_path(parent)
            end
          else
            flash[:notice] = t('flash.attendee.create.success')
            EmailNotifications.registration_pending(@attendee).deliver
            @attendee.email_sent = true
            @attendee.save
            redirect_to root_path
          end
        rescue e
          flash[:alert] = t('flash.attendee.mail.fail')
          redirect_to root_path
        end
      end
      failure.html do
        flash.now[:error] = t('flash.failure')
        render :new
      end
    end
  end
  
  def pre_registered
    pre_registration = PreRegistration.registered(params[:email]).first
    pre_registered = (not pre_registration.nil?) && (not pre_registration.used?)
    respond_to do |format|
      format.js { render :js => pre_registered.to_s }
    end
  end
  
  private
  def build_resource
    attributes = params[:attendee] || {}
    attributes[:conference_id] = current_conference.id
    if parent?
      attributes[:registration_type_id] = RegistrationType.find_by_title('registration_type.group').id
      attributes[:organization] = parent.name
    end
    @attendee ||= end_of_association_chain.send(method_for_build, attributes)
  end
  
  def load_registration_types
    @registration_types ||= parent? ? RegistrationType.all : RegistrationType.without_group.all
  end
  
  def validate_total_attendees
    if parent? && parent.complete?
      flash[:error] = t('flash.attendee.registration_group.complete', :total_attendees => parent.total_attendees)
      redirect_to root_path
    end
  end
end