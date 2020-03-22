# frozen_string_literal: true

Conference.seed do |conference|
  conference.id                   = 1
  conference.name                 = 'Agile Brazil 2010'
  conference.year                 = 2010
  conference.location_and_date    = 'Porto Alegre RS, 22-25 Jun/2010'
  conference.location             = 'Porto Alegre RS'
  conference.start_date           = Time.zone.local(2010, 6, 22)
  conference.end_date             = Time.zone.local(2010, 6, 25)
  conference.call_for_papers      = Time.zone.local(2010, 1, 31)
  conference.submissions_open     = Time.zone.local(2010, 1, 31)
  conference.submissions_deadline = Time.zone.local(2010, 3, 7, 23, 59, 59)
  conference.review_deadline      = Time.zone.local(2010, 4, 23, 23, 59, 59)
  conference.author_notification  = Time.zone.local(2010, 5, 3, 23, 59, 59)
  conference.author_confirmation  = Time.zone.local(2010, 5, 17, 23, 59, 59)
  conference.visible              = true
  conference.supported_languages  = ['en', 'pt-BR']
  conference.tag_limit            = 10
end

Conference.seed do |conference|
  conference.id                   = 2
  conference.name                 = 'Agile Brazil 2011'
  conference.year                 = 2011
  conference.location_and_date    = 'Fortaleza CE, 27/Jun - 1/Jul, 2011'
  conference.location             = 'Fortaleza CE'
  conference.start_date           = Time.zone.local(2011, 6, 27)
  conference.end_date             = Time.zone.local(2011, 7, 1)
  conference.call_for_papers      = Time.zone.local(2011, 2, 5)
  conference.submissions_open     = Time.zone.local(2011, 2, 14)
  conference.submissions_deadline = Time.zone.local(2011, 3, 27, 23, 59, 59)
  conference.review_deadline      = Time.zone.local(2011, 4, 17, 23, 59, 59)
  conference.author_notification  = Time.zone.local(2011, 4, 30, 23, 59, 59)
  conference.author_confirmation  = Time.zone.local(2011, 6, 7, 23, 59, 59)
  conference.visible              = true
  conference.supported_languages  = ['en', 'pt-BR']
  conference.tag_limit            = 10
end

Conference.seed do |conference|
  conference.id                      = 3
  conference.name                    = 'Agile Brazil 2012'
  conference.year                    = 2012
  conference.location_and_date       = 'São Paulo SP, 3-7 Set, 2012'
  conference.location                = 'São Paulo SP'
  conference.start_date              = Time.zone.local(2012, 9, 3)
  conference.end_date                = Time.zone.local(2012, 9, 7)
  conference.call_for_papers         = nil # No official call for papers
  conference.submissions_open        = Time.zone.local(2012, 3, 22)
  conference.presubmissions_deadline = Time.zone.local(2012, 4, 15, 23, 59, 59)
  conference.prereview_deadline      = Time.zone.local(2012, 4, 29, 23, 59, 59)
  conference.submissions_deadline    = Time.zone.local(2012, 5, 13, 23, 59, 59)
  conference.review_deadline         = Time.zone.local(2012, 6, 3, 23, 59, 59)
  conference.author_notification     = Time.zone.local(2012, 6, 24, 23, 59, 59)
  conference.author_confirmation     = Time.zone.local(2012, 7, 4, 23, 59, 59)
  conference.visible                 = true
  conference.supported_languages     = ['en', 'pt-BR']
  conference.tag_limit               = 10
end

Conference.seed do |conference|
  conference.id                      = 4
  conference.name                    = 'Agile Brazil 2013'
  conference.year                    = 2013
  conference.location_and_date       = 'Brasília DF, 26-28 Jun, 2013'
  conference.location                = 'Brasília DF'
  conference.start_date              = Time.zone.local(2013, 6, 26)
  conference.end_date                = Time.zone.local(2013, 6, 28)
  conference.call_for_papers         = Time.zone.local(2013, 1, 27)
  conference.submissions_open        = Time.zone.local(2013, 2, 8)
  conference.presubmissions_deadline = nil # No pre review
  conference.prereview_deadline      = nil # No pre review
  conference.submissions_deadline    = Time.zone.local(2013, 4, 7, 23, 59, 59)
  conference.review_deadline         = Time.zone.local(2013, 5, 2, 23, 59, 59)
  conference.voting_deadline         = Time.zone.local(2013, 5, 14, 23, 59, 59)
  conference.author_notification     = Time.zone.local(2013, 5, 15, 23, 59, 59)
  conference.author_confirmation     = Time.zone.local(2013, 6, 10, 2, 59, 59)
  conference.visible                 = true
  conference.supported_languages     = ['en', 'pt-BR']
  conference.tag_limit               = 10
end

Conference.seed do |conference|
  conference.id                      = 5
  conference.name                    = 'Agile Brazil 2014'
  conference.year                    = 2014
  conference.location_and_date       = 'Florianópolis SC, 5-7 Nov, 2014'
  conference.location                = 'Florianópolis SC'
  conference.start_date              = Time.zone.local(2014, 11, 5)
  conference.end_date                = Time.zone.local(2014, 11, 7)
  conference.call_for_papers         = Time.zone.local(2014, 5, 7)
  conference.submissions_open        = Time.zone.local(2014, 5, 14)
  conference.presubmissions_deadline = nil # No pre review
  conference.prereview_deadline      = nil # No pre review
  conference.submissions_deadline    = Time.zone.local(2014, 7, 20, 23, 59, 59)
  conference.review_deadline         = Time.zone.local(2014, 8, 11, 23, 59, 59)
  conference.voting_deadline         = nil # No voting
  conference.author_notification     = Time.zone.local(2014, 8, 25, 23, 59, 59)
  conference.author_confirmation     = Time.zone.local(2014, 9, 4, 2, 59, 59)
  conference.visible                 = true
  conference.supported_languages     = ['en', 'pt-BR']
  conference.allow_free_form_tags    = false
  conference.tag_limit               = 10
end

Conference.seed do |conference|
  conference.id                      = 6
  conference.name                    = 'Agile Brazil 2015'
  conference.year                    = 2015
  conference.location_and_date       = 'Porto de Galinhas PE, 21-23 Oct, 2015'
  conference.location                = 'Porto de Galinhas PE'
  conference.start_date              = Time.zone.local(2015, 10, 21)
  conference.end_date                = Time.zone.local(2015, 10, 23)
  conference.call_for_papers         = Time.zone.local(2015, 4, 30)
  conference.submissions_open        = Time.zone.local(2015, 5, 4)
  conference.presubmissions_deadline = nil # No pre review
  conference.prereview_deadline      = nil # No pre review
  conference.submissions_deadline    = Time.zone.local(2015, 6, 28, 23, 59, 59)
  conference.review_deadline         = Time.zone.local(2015, 7, 21, 23, 59, 59)
  conference.voting_deadline         = nil # No voting
  conference.author_notification     = Time.zone.local(2015, 8, 1, 23, 59, 59)
  conference.author_confirmation     = Time.zone.local(2015, 8, 10, 23, 59, 59)
  conference.visible                 = true
  conference.supported_languages     = ['en', 'pt-BR']
  conference.allow_free_form_tags    = false
  conference.tag_limit               = 10
end
