describe "OrganizerReviews", ->

  describe ".load", ->

    beforeEach ->
      setFixtures(
        "<div id='sandbox'>"+
          "<a href='#' class='hide'>Hide</a>" +
          "<a href='#' class='show'>Show</a>" +
          "<div class='justification'>Some justification</div>" +
        "</div>"
      )
      new OrganizerReviews('#sandbox').load()

    it "should display all justifications", ->
      expect($('.justification')).toBeVisible()

    it "should display all links to hide justifications", ->
      expect($('.hide')).toBeVisible()
      expect($('.show')).toBeHidden()

    it "clicking 'hide' should hide the justification and toggle the 'show' link", ->
      $('.hide').click()
      expect($('.hide')).toBeHidden()
      expect($('.show')).toBeVisible()
      expect($('.justification')).toBeHidden()