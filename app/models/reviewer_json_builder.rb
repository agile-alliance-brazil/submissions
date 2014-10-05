class ReviewerJsonBuilder
  def initialize(reviewer)
    @reviewer = reviewer
  end
  def to_json
    {
      id: @reviewer.id,
      full_name: @reviewer.user.full_name,
      username: @reviewer.user.username,
      status: I18n.t("reviewer.state.#{@reviewer.state}"),
      url: Rails.application.routes.url_helpers.reviewer_path(@reviewer.conference, @reviewer)
    }
  end
end