# encoding: UTF-8
module RegisteredGroupsHelper
  def registration_group_status_options
    [
      [I18n.t('registration_group.status.all'), nil],
      [I18n.t('registration_group.status.incomplete'), 'incomplete'],
      [I18n.t('registration_group.status.complete'), 'complete'],
      [I18n.t('registration_group.status.paid'), 'paid'],
      [I18n.t('registration_group.status.confirmed'), 'confirmed']
    ]
  end
end
