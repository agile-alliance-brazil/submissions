# encoding: UTF-8
# frozen_string_literal: true

Outcome.seed do |outcome|
  outcome.id = 1
  outcome.title = 'outcomes.accept.title'
  outcome.order = 2
end

Outcome.seed do |outcome|
  outcome.id = 2
  outcome.title = 'outcomes.reject.title'
  outcome.order = -1
end

Outcome.seed do |outcome|
  outcome.id = 3
  outcome.title = 'outcomes.backup.title'
  outcome.order = 1
end
