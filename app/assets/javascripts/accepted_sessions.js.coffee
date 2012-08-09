#= require jquery
#= require jquery_ujs
#= require_self

class AcceptedSessions
  load: ->
    $(".bio").hide()

(exports ? this).AcceptedSessions = AcceptedSessions

jQuery ->
  new AcceptedSessions().load()