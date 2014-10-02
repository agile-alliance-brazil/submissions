#= require jquery
#= require_self
(($) ->
  $.submissions = $.submissions || {}
  $.submissions.reviewers = $.submissions.reviewers || {}

  $.submissions.reviewers.initializeAutocomplete = (autocompleteId, usersPath, valuesToExclude) ->
    users = undefined
    complete = (matcher, response) ->
      reviewerUsernames = valuesToExclude()
      response $.grep(users, (item) ->
        ($.inArray(item, reviewerUsernames) < 0) and matcher.test(item)
      )

    $(autocompleteId).autocomplete source: (request, response) ->
        matcher = new RegExp("^" + $.ui.autocomplete.escapeRegex(request.term), "i")
        if typeof users is "undefined"
          $.ajax
            url: usersPath,
            dataType: "json",
            success: (data, status, xhr) ->
              users = data;
              complete matcher, response
        else
          complete matcher, response

  $.submissions.reviewers.initializeRemoveLinksFeedback = (linkSelector) ->
    $(linkSelector).bind("ajax:beforeSend", () ->
      $(this).hide()
      $("#flash_notice_ajax").hide()
      $("#flash_error_ajax").hide()
    ).bind("ajax:success", (xhr, status, event) ->
      $(this).closest("tr").remove()
      $("#flash_notice_ajax").text(status.message)
      $("#flash_notice_ajax").show()
    ).bind("ajax:error", (xhr, status, event) ->
      $(this).show()
      $("#flash_error_ajax").text(status.responseText)
      $("#flash_error_ajax").show()
    )

  $.submissions.reviewers.initializeAddFormFeedback = (formSelector, mockSelector, appendableSelector) ->
    $(formSelector).bind("ajax:beforeSend", () ->
      $(this).find(":submit").prop "disabled", true
      $("#flash_notice_ajax").hide()
      $("#flash_error_ajax").hide()
    ).bind("ajax:success", (xhr, status, event) ->
      className = (if ($(appendableSelector).children("tr:visible").size() % 2) is 0 then "odd" else "even")
      clone = newRowWithData $(mockSelector), status.reviewer, className
      clone.appendTo($(appendableSelector))
      $("#flash_notice_ajax").text status.message
      $("#flash_notice_ajax").show()
    ).bind("ajax:error", (xhr, status, event) ->
      $("#flash_error_ajax").text status.responseText
      $("#flash_error_ajax").show()
    ).bind("ajax:complete", () ->
      $(this).find("input[type=text]").val ""
      $(this).find(":submit").prop "disabled", false
    )

  newRowWithData = (mockRow, reviewer, className) ->
    clone = mockRow.clone true, true
    clone.addClass className
    clone.removeClass "hidden"
    clone.attr "id", ("reviewer_" + reviewer.id)
    clone.data "username", reviewer.username
    clone.find("td.reviewer").text reviewer.full_name
    clone.find("td.state").text reviewer.status
    clone.find("a.remove").attr "href", reviewer.url
    clone
)(jQuery)
