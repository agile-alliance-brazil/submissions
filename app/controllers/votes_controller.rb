#encoding:utf-8
class VotesController < InheritedResources::Base
  actions :index, :create, :destroy

  private

  def build_resource
    attributes = params[:vote] || {}
    attributes[:conference_id] = @conference.id
    attributes[:user_id] = current_user.id
    @vote ||= end_of_association_chain.send(method_for_build, attributes)
  end

  def collection
    @sessions ||= current_user.voted_sessions.for_conference(@conference)
  end

  def smart_collection_url
    request.referer
  end
end
