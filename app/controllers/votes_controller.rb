#encoding:utf-8
class VotesController < InheritedResources::Base
  actions :index, :create, :destroy

  private

  def resource_params
    super.tap do |attributes|
      attributes.first[:conference_id] = @conference.id
      attributes.first[:user_id] = current_user.id
    end
  end

  def collection
    @sessions ||= current_user.voted_sessions.for_conference(@conference)
  end

  def smart_collection_url
    request.referer
  end
end
