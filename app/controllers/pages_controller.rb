# encoding: UTF-8
class PagesController < ApplicationController
  skip_before_filter :authenticate_user!, only: :show

  def show
    @page = resource
    if @page
      render :show
    else
      render template: "static_pages/#{@conference.year}_#{path}"
    end
  end

  def new
    @page = Page.new((params[:page] && new_page_attributes) || {})
  end

  def create
    @page = Page.new(new_page_attributes)
    if @page.save
      redirect_to conference_page_path(@conference, @page)
    else
      flash.now[:error] = t('flash.failure')
      render :new
    end
  end

  def edit
    @page = resource
  end

  def update
    @page = resource
    attrs = update_page_attributes
    attrs = attrs.merge({path: 'home'}) if @page.path == '/' || @page.path.blank? # TODO Legacy, remove
    if @page.update_attributes(attrs)
      redirect_to conference_page_path(@conference, @page)
    else
      flash.now[:error] = t('flash.failure')
      render :edit
    end
  end

  private
  def resource
    Page.where(id: params[:id]).first || Page.for_conference(@conference).with_path(path).first
  end

  def path
    params[:path] || 'home'
  end

  def resource_class
    Page
  end

  def new_page_attributes
    attrs = params.require(:page).permit(:path, translated_contents_attributes: [:language, :title, :description])
    attrs.merge(conference_id: @conference.id)
  end

  def update_page_attributes
    params.require(:page).permit(translated_contents_attributes: [:id, :language, :title, :description])
  end
end
