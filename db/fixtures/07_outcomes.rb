# encoding: UTF-8
# frozen_string_literal: true

Outcome.seed do |outcome|
  outcome.id = 1
  outcome.title = 'outcomes.accept.title'
end

Outcome.seed do |outcome|
  outcome.id = 2
  outcome.title = 'outcomes.reject.title'
end

Outcome.seed do |outcome|
  outcome.id = 3
  outcome.title = 'outcomes.backup.title'
end
