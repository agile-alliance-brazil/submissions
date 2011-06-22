RegistrationPeriod.seed do |period|
  period.id = 1
  period.conference_id = 2
  period.title = 'registration_period.pre_register'
  period.start_at = Time.zone.local(2011, 4, 4)
  period.end_at = Time.zone.local(2011, 4, 13).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 2
  period.conference_id = 2
  period.title = 'registration_period.early_bird'
  period.start_at = Time.zone.local(2011, 4, 4)
  period.end_at = Time.zone.local(2011, 5, 25).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 3
  period.conference_id = 2
  period.title = 'registration_period.regular'
  period.start_at = Time.zone.local(2011, 5, 26)
  period.end_at = Time.zone.local(2011, 6, 22).end_of_day
end

RegistrationPeriod.seed do |period|
  period.id = 4
  period.conference_id = 2
  period.title = 'registration_period.late'
  period.start_at = Time.zone.local(2011, 6, 27)
  period.end_at = Time.zone.local(2011, 7, 1).end_of_day
end