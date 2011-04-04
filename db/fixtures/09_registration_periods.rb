RegistrationPeriod.seed do |period|
  period.id = 1
  period.conference_id = 2
  period.start_at = Time.zone.local(2011, 4, 4)
  period.end_at = Time.zone.local(2011, 4, 11, 23, 59, 59)
end

RegistrationPeriod.seed do |period|
  period.id = 2
  period.conference_id = 2
  period.start_at = Time.zone.local(2011, 4, 4)
  period.end_at = Time.zone.local(2011, 5, 23, 23, 59, 59)
end

RegistrationPeriod.seed do |period|
  period.id = 3
  period.conference_id = 2
  period.start_at = Time.zone.local(2011, 5, 24)
  period.end_at = Time.zone.local(2011, 6, 20, 23, 59, 59)
end

RegistrationPeriod.seed do |period|
  period.id = 4
  period.conference_id = 2
  period.start_at = Time.zone.local(2011, 6, 21)
  period.end_at = Time.zone.local(2011, 6, 27)
end