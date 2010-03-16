class ReviewersController < InheritedResources::Base
  actions :index, :new, :create, :destroy
  respond_to :html
  
  def create
    create! do |success, failure|
      success.html do
        flash[:notice] = t('flash.reviewer.create.success')
        redirect_to reviewers_path
      end
      failure.html do
        flash.now[:error] = t('flash.failure')
        render :new
      end
    end
  end
  
  protected
  def collection
    paginate_options ||= {}
    paginate_options[:page] ||= (params[:page] || 1)
    paginate_options[:per_page] ||= (params[:per_page] || 10)
    paginate_options[:order] ||= 'reviewers.created_at DESC'
    @reviewers ||= end_of_association_chain.paginate(paginate_options)
  end
end