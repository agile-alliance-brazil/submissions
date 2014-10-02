class OrganizerReviews
  constructor: (containerId) ->
    @container = $(containerId)

  load: ->
    $("a.show", @container).hide()
    $("a.show, a.hide", @container).click ->
      $(this).closest('tr').next().find('.justification').toggle()
      $(this).siblings().toggle()
      $(this).toggle()
      return false

(exports ? this).OrganizerReviews = OrganizerReviews