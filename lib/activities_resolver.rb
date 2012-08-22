# encoding: UTF-8
class ActivitiesResolver < ::ActionView::FileSystemResolver
  def initialize
    super("app/views")
  end

  def find_templates(name, prefix, partial, details)
    super(name, 'accepted_sessions', partial, details)
  end
end