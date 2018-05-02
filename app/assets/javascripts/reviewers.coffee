#= require jquery

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
      appendNewRowWithData(mockSelector, appendableSelector, status.reviewer)
      $("#flash_notice_ajax").text status.message
      $("#flash_notice_ajax").show()
    ).bind("ajax:error", (xhr, status, event) ->
      $("#flash_error_ajax").text status.responseText
      $("#flash_error_ajax").show()
    ).bind("ajax:complete", () ->
      $(this).find("input[type=text]").val ""
      $(this).find(":submit").prop "disabled", false
    )

  $.submissions.reviewers.initializeAddMultipleFormFeedback = (formSelector, mockSelector, appendableSelector) ->
    $(formSelector).bind("ajax:beforeSend", () ->
      $(this).find(":submit").prop "disabled", true
      $("#flash_notice_ajax").hide()
      $("#flash_error_ajax").hide()
    ).bind("ajax:success", (xhr, status, event) ->
      $.each(status.new_reviewers, (index, reviewer) ->
        appendNewRowWithData(mockSelector, appendableSelector, reviewer)
        $(formSelector).find('tr#'+reviewer.username).remove()
        if $(formSelector).find('tbody tr').size() == 0
          $(formSelector).prev('h3').hide()
          $(formSelector).hide()
      )
      if not (typeof status.success_message is "undefined")
        $("#flash_notice_ajax").text status.success_message
        $("#flash_notice_ajax").show()
      failures = ""
      $.each(status.failed_invites, (index, failure) ->
        failures += failure + "<br/>"
      )
      if failures != ""
        $("#flash_error_ajax").html failures
        $("#flash_error_ajax").show()
    ).bind("ajax:complete", () ->
      $(this).find(":submit").prop "disabled", false
    )

  $.submissions.reviewers.initializeEmailInteraction = (parentSelector) ->
    displayerItems = $(parentSelector).find('.display')
    hiderItems = $(parentSelector).find('.hide')
    copierItems = $(parentSelector).find('.copy')
    copyValue = $(parentSelector).find('.copy_value')

    displayerItems.click(() ->
      displayerItems.addClass('hidden')
      hiderItems.removeClass('hidden')
      copyValue.removeClass('hidden')
    )
    displayerItems.addClass('clickable')
    displayerItems.removeClass('hidden')

    hiderItems.click(() ->
      displayerItems.removeClass('hidden')
      hiderItems.addClass('hidden')
      copyValue.addClass('hidden')
    )
    hiderItems.addClass('clickable')

    copierItems.click(() ->
      temp = $("<input>")
      $("body").append(temp)
      temp.val($(copyValue).text()).select()
      document.execCommand("copy")
      temp.remove()
    )
    copierItems.addClass('clickable')
    copierItems.removeClass('hidden')

    copyValue.addClass('hidden')


  appendNewRowWithData = (mockSelector, appendableSelector, reviewer) ->
    className = (if ($(appendableSelector).children("tr:visible").size() % 2) is 0 then "odd" else "even")
    clone = newRowWithData $(mockSelector), reviewer, className
    clone.appendTo($(appendableSelector))

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
