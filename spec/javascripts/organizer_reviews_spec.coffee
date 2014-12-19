#=require spec_helper
#=require organizer_reviews

describe "OrganizerReviews", ->
  describe ".load", ->
    beforeEach ->
      $('#konacha').append(
        "<div id='sandbox'>"+
          "<a href='#' class='hide'>Hide</a>" +
          "<a href='#' class='show'>Show</a>" +
          "<div class='justification'>Some justification</div>" +
        "</div>"
      )
      new OrganizerReviews('#sandbox').load()

    it "should display all justifications", ->
      expect($('.justification')).to.be.visible

    it "should display all links to hide justifications", ->
      expect($('.hide')).to.be.visible
      expect($('.show')).to.be.hidden

    it "clicking 'hide' should hide the justification and toggle the 'show' link", ->
      $('.hide').click()
      expect($('.hide')).to.be.hidden
      expect($('.show')).to.be.visible
      expect($('.justification')).to.be.hidden
