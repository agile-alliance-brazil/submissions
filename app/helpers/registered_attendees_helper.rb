module RegisteredAttendeesHelper
  def attendee_status_options
    [
      [I18n.t('attendee.status.all'), nil],
      [I18n.t('attendee.status.pending'), 'pending'],
      [I18n.t('attendee.status.confirmed'), 'confirmed']
    ]
  end
end