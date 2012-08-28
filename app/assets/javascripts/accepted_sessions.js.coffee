#= require jquery
#= require jquery_ujs
#= require fancybox
#= require_self

class AcceptedSessions
  load: ->
    $("#accepted_sessions .bio").hide()
    $("#accepted_sessions table .content").each ->
      # Setting .content height to TD height to allow absolute positioning of tabs
      $(this).height($(this).closest('td').height())
      # Aligning .details in the middle (vertically)
      innerHeight = $(this).children('.details').height()
      $(this).children('.details').css("margin-top", -(innerHeight / 2) + 'px')
    $("#accepted_sessions table td.keynote}").each ->
      $(this).closest("tr").height($(this).height() * 3)
    $('#accepted_sessions .fancybox').fancybox()

jQuery ->
  new AcceptedSessions().load()

(exports ? this).AcceptedSessions = AcceptedSessions