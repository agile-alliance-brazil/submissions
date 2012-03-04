# encoding: UTF-8
Conference.seed do |conference|
  conference.id                   = 1
  conference.name                 = 'Agile Brazil 2010'
  conference.year                 = 2010
  conference.location_and_date    = 'Porto Alegre RS, 22-25 Jun/2010'
  conference.call_for_papers      = Time.zone.local(2010, 1, 31)
  conference.submissions_open     = Time.zone.local(2010, 1, 31)
  conference.submissions_deadline = Time.zone.local(2010, 3, 7, 23, 59, 59)
  conference.review_deadline      = Time.zone.local(2010, 4, 23, 23, 59, 59)
  conference.author_notification  = Time.zone.local(2010, 5, 3, 23, 59, 59)
  conference.author_confirmation  = Time.zone.local(2010, 5, 17, 23, 59, 59)
end

Conference.seed do |conference|
  conference.id                   = 2
  conference.name                 = 'Agile Brazil 2011'
  conference.year                 = 2011
  conference.location_and_date    = 'Fortaleza CE, 27/Jun - 1/Jul, 2011'
  conference.call_for_papers      = Time.zone.local(2011, 2, 5)
  conference.submissions_open     = Time.zone.local(2011, 2, 14)
  conference.submissions_deadline = Time.zone.local(2011, 3, 27, 23, 59, 59)
  conference.review_deadline      = Time.zone.local(2011, 4, 17, 23, 59, 59)
  conference.author_notification  = Time.zone.local(2011, 4, 30, 23, 59, 59)
  conference.author_confirmation  = Time.zone.local(2011, 6, 7, 23, 59, 59)
end

Conference.seed do |conference|
  conference.id                   = 3
  conference.name                 = 'Agile Brazil 2012'
  conference.year                 = 2012
  conference.location_and_date    = 'São Paulo SP, Jun - Jul, 2012'
  conference.call_for_papers      = Time.zone.local(2012, 2, 5)
  conference.submissions_open     = Time.zone.local(2012, 3, 7)
  conference.submissions_deadline = Time.zone.local(2012, 4, 6, 23, 59, 59)
  conference.review_deadline      = Time.zone.local(2012, 4, 28, 23, 59, 59)
  conference.author_notification  = Time.zone.local(2012, 5, 10, 23, 59, 59)
  conference.author_confirmation  = Time.zone.local(2012, 5, 25, 23, 59, 59)
end
