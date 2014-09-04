# encoding: UTF-8
Conference.seed do |conference|
  conference.id                   = 1
  conference.name                 = 'AWID 13th Forum'
  conference.year                 = 2016
  conference.location_and_date    = 'Salvador, Brazil, May/2016'
  conference.call_for_papers      = Time.zone.local(2015, 1, 1)
  conference.submissions_open     = Time.zone.local(2015, 3, 1)
  conference.submissions_deadline = Time.zone.local(2015, 5, 31, 23, 59, 59)
  conference.review_deadline      = Time.zone.local(2015, 6, 30, 23, 59, 59)
  conference.author_notification  = Time.zone.local(2015, 7, 31, 23, 59, 59)
  conference.author_confirmation  = Time.zone.local(2015, 8, 15, 23, 59, 59)
end
