#= require jquery
#= require jquery_ujs
#= require fancybox
#= require_self

class AcceptedSessions
  load: ->
    $(".bio").hide()
    $("table .content").each ->
      # Setting .content height to TD height to allow absolute positioning of tabs
      $(this).height($(this).closest('td').height())
      # Aligning .details in the middle (vertically)
      innerHeight = $(this).children('.details').height()
      $(this).children('.details').css("margin-top", -(innerHeight / 2) + 'px')
    $('.fancybox').fancybox()

jQuery ->
  new AcceptedSessions().load()

(exports ? this).AcceptedSessions = AcceptedSessions