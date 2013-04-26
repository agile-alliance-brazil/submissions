# encoding: UTF-8
class ReviewersController < InheritedResources::Base
  actions :index, :new, :create, :destroy
  respond_to :html
  before_filter :load_reviewer_filter, :only => :index
  before_filter :load_tracks, :only => :index
  before_filter :load_states, :only => :index

  has_scope :filtered, :only => :index, :as => :reviewer_filter, :type => :hash do |controller, scope, value|
    controller.send(:load_reviewer_filter).apply(scope)
  end
  
  def create
    create! do |success, failure|
      success.html do
        flash[:notice] = t('flash.reviewer.create.success')
        redirect_to reviewers_path(@conference)
      end
      failure.html do
        flash.now[:error] = t('flash.failure')
        render :new
      end
    end
  end
    
  def destroy
    destroy! { reviewers_path(@conference) }
  end
  
  protected
  def resource_params
    super.tap do |attributes|
      attributes.first[:conference_id] = @conference.id
    end
  end

  def collection
    @reviewers ||= end_of_association_chain.
      for_conference(@conference).
      joins(:user).
      order('first_name, last_name')
  end

  def load_tracks
    @tracks ||= @conference.tracks
  end

  def load_states
    @states ||= Reviewer.state_machine.states.map(&:name)
  end

  def load_reviewer_filter
    @reviewer_filter ||= ReviewerFilter.new(params)
  end
end
