# encoding: UTF-8
Conference.seed do |conference|
  conference.id                   = 1
  conference.name                 = 'AWID 13th Forum (pending confirmation)'
  conference.year                 = 2013
  conference.location_and_date    = 'Salvador, Brazil, May/2016'
  conference.call_for_papers      = Time.zone.local(2014, 1, 1)
  conference.submissions_open     = Time.zone.local(2014, 3, 1)
  conference.submissions_deadline = Time.zone.local(2014, 5, 31, 23, 59, 59)
  conference.review_deadline      = Time.zone.local(2014, 6, 30, 23, 59, 59)
  conference.author_notification  = Time.zone.local(2014, 7, 31, 23, 59, 59)
  conference.author_confirmation  = Time.zone.local(2014, 9, 15, 23, 59, 59)
end
Conference.seed do |conference|
  conference.id                   = 1
  conference.name                 = 'AWID 13th Forum (selecting)'
  conference.year                 = 2014
  conference.location_and_date    = 'Salvador, Brazil, May/2016'
  conference.call_for_papers      = Time.zone.local(2014, 1, 1)
  conference.submissions_open     = Time.zone.local(2014, 3, 1)
  conference.submissions_deadline = Time.zone.local(2014, 5, 31, 23, 59, 59)
  conference.review_deadline      = Time.zone.local(2014, 6, 30, 23, 59, 59)
  conference.author_notification  = Time.zone.local(2014, 9, 31, 23, 59, 59)
  conference.author_confirmation  = Time.zone.local(2014, 10, 15, 23, 59, 59)
end
Conference.seed do |conference|
  conference.id                   = 1
  conference.name                 = 'AWID 13th Forum (reviewing)'
  conference.year                 = 2015
  conference.location_and_date    = 'Salvador, Brazil, May/2016'
  conference.call_for_papers      = Time.zone.local(2014, 1, 1)
  conference.submissions_open     = Time.zone.local(2014, 3, 1)
  conference.submissions_deadline = Time.zone.local(2014, 5, 31, 23, 59, 59)
  conference.review_deadline      = Time.zone.local(2014, 9, 15, 23, 59, 59)
  conference.author_notification  = Time.zone.local(2014, 9, 30, 23, 59, 59)
  conference.author_confirmation  = Time.zone.local(2014, 10, 31, 23, 59, 59)
end
Conference.seed do |conference|
  conference.id                   = 1
  conference.name                 = 'AWID 13th Forum (proposals)'
  conference.year                 = 2016
  conference.location_and_date    = 'Salvador, Brazil, May/2016'
  conference.call_for_papers      = Time.zone.local(2014, 1, 1)
  conference.submissions_open     = Time.zone.local(2014, 3, 1)
  conference.submissions_deadline = Time.zone.local(2014, 9, 30, 23, 59, 59)
  conference.review_deadline      = Time.zone.local(2014, 10, 31, 23, 59, 59)
  conference.author_notification  = Time.zone.local(2014, 11, 30, 23, 59, 59)
  conference.author_confirmation  = Time.zone.local(2014, 12, 31, 23, 59, 59)
end
