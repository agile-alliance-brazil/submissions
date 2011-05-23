class RegistrationReminder
  def publish
    pending_attendees.each do |attendee|
      Rails.logger.info("[ATTENDEE] #{attendee.to_param}")
      try_with("REMINDER") do
        EmailNotifications.registration_reminder(attendee).deliver
      end
    end
  end
  
  private
  def pending_attendees
    Attendee.all(:conditions => ['conference_id = ? AND status = ?', current_conference.id, 'pending'])
  end
  
  def try_with(action, &blk)
    blk.call
    Rails.logger.info("  [#{action}] OK")
  rescue => e
    HoptoadNotifier.notify(e)
    Rails.logger.info("  [FAILED #{action}] #{e.message}")
  ensure
    Rails.logger.flush
  end
  
  def current_conference
    @current_conference ||= Conference.current
  end
end