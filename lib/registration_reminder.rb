# encoding: UTF-8
class RegistrationReminder
  def publish
    pending_attendees.each do |attendee|
      Rails.logger.info("[ATTENDEE] #{attendee.to_param}")
      try_with("REMINDER") do
        EmailNotifications.registration_reminder(attendee).deliver
        sleep(5) unless Rails.env.test?
      end
    end
  end
  
  private
  def pending_attendees
    Attendee.all(:conditions => ['conference_id = ? AND status = ? AND registration_type_id <> ? AND registration_date < ?', current_conference.id, 'pending', RegistrationType.find_by_title('registration_type.group').id, Time.zone.local(2011, 5, 21)], :order => 'id')
  end
  
  def try_with(action, &blk)
    blk.call
    Rails.logger.info("  [#{action}] OK")
  rescue => e
    Airbrake.notify(e)
    Rails.logger.info("  [FAILED #{action}] #{e.message}")
  ensure
    Rails.logger.flush
  end
  
  def current_conference
    @current_conference ||= Conference.current
  end
end
