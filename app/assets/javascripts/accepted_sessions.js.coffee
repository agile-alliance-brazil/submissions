#= require jquery
#= require jquery_ujs
#= require_self

class AcceptedSessions
  load: ->
    $(".bio").hide()

jQuery ->
  new AcceptedSessions().load()

(exports ? this).AcceptedSessions = AcceptedSessions