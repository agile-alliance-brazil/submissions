# encoding: UTF-8
# frozen_string_literal: true

require 'rubygems'
require 'scrapi'
require 'activesupport'
require 'faster_csv'

Tidy.path = '/usr/lib/libtidy.dylib'

session_scraper = Scraper.define do
  process 'a', session_id: '@name'
  process 'ul:nth-child(5)>li:nth-child(2)', date: :text
  process 'ul:nth-child(5)>li:nth-child(3)', start_at: :text
  process 'ul:nth-child(4)>li:nth-child(3)', duration: :text

  result :session_id, :date, :start_at, :duration
end

schedule = Scraper.define do
  array :sessions

  process '.session', sessions: session_scraper

  result :sessions
end

html = File.read('schedule.html')
sessions = schedule.scrape(html)

FasterCSV.open('sessions.csv', 'w') do |csv|
  csv << %w[session_id start_at end_at]

  sessions.each do |session|
    day = session.date.match(%r{\d+/\d+})[0]
    start_at = DateTime.strptime(day + '/2011 ' + session.start_at, '%d/%m/%Y %H:%M')
    end_at = session.duration =~ /50/ ? start_at + 1.hour : start_at + 2.hours
    csv << [session.session_id, start_at, end_at]
  end
end
