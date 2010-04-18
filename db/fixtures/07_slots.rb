# General Interest

Slot.seed do |slot|
  slot.id = 1
  slot.track = Track.find_by_title('tracks.general_interest.title')
  slot.start_at = Time.zone.local(2010, 6, 24, 8, 0, 0)
  slot.end_at = Time.zone.local(2010, 6, 24, 8, 45, 0)
  slot.duration_mins = 45
end

Slot.seed do |slot|
  slot.id = 2
  slot.track = Track.find_by_title('tracks.general_interest.title')
  slot.start_at = Time.zone.local(2010, 6, 24, 8, 45, 0)
  slot.end_at = Time.zone.local(2010, 6, 24, 9, 30, 0)
  slot.duration_mins = 45
end

# Management

Slot.seed do |slot|
  slot.id = 3
  slot.track = Track.find_by_title('tracks.management.title')
  slot.start_at = Time.zone.local(2010, 6, 24, 8, 0, 0)
  slot.end_at = Time.zone.local(2010, 6, 24, 8, 45, 0)
  slot.duration_mins = 45
end

Slot.seed do |slot|
  slot.id = 4
  slot.track = Track.find_by_title('tracks.management.title')
  slot.start_at = Time.zone.local(2010, 6, 24, 8, 45, 0)
  slot.end_at = Time.zone.local(2010, 6, 24, 9, 30, 0)
  slot.duration_mins = 45
end

# Engineering

Slot.seed do |slot|
  slot.id = 5
  slot.track = Track.find_by_title('tracks.engineering.title')
  slot.start_at = Time.zone.local(2010, 6, 24, 8, 0, 0)
  slot.end_at = Time.zone.local(2010, 6, 24, 8, 45, 0)
  slot.duration_mins = 45
end

Slot.seed do |slot|
  slot.id = 6
  slot.track = Track.find_by_title('tracks.engineering.title')
  slot.start_at = Time.zone.local(2010, 6, 24, 8, 45, 0)
  slot.end_at = Time.zone.local(2010, 6, 24, 9, 30, 0)
  slot.duration_mins = 45
end

# Experience Reports

Slot.seed do |slot|
  slot.id = 7
  slot.track = Track.find_by_title('tracks.experience_reports.title')
  slot.start_at = Time.zone.local(2010, 6, 24, 8, 0, 0)
  slot.end_at = Time.zone.local(2010, 6, 24, 8, 45, 0)
  slot.duration_mins = 45
end

Slot.seed do |slot|
  slot.id = 8
  slot.track = Track.find_by_title('tracks.experience_reports.title')
  slot.start_at = Time.zone.local(2010, 6, 24, 8, 45, 0)
  slot.end_at = Time.zone.local(2010, 6, 24, 9, 30, 0)
  slot.duration_mins = 45
end
