#= require jquery
#= require jquery_ujs
#= require fancybox
#= require_self

class AcceptedSessions
  constructor: (containerId) ->
    @container = $(containerId)

  load: ->
    $(".bio", @container).hide()
    $("table .content", @container).each ->
      # Setting .content height to TD height to allow absolute positioning of tabs
      $(this).height($(this).closest("td").height())
      # Aligning .details in the middle (vertically)
      innerHeight = $(this).children(".details").height()
      $(this).children(".details").css("margin-top", -(innerHeight / 2) + 'px')
    $("table td.keynote", @container).each ->
      $(this).closest("tr").height($(this).height() * 3)
    $(".fancybox", @container).fancybox()

jQuery ->
  new AcceptedSessions("#accepted_sessions").load()

(exports ? this).AcceptedSessions = AcceptedSessions