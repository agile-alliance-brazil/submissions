describe "AcceptedSessions", ->

  describe ".load", ->

    it "should hide all authors' bio", ->
      setFixtures("<div id='sandbox'><div class='bio'></div></div>")
      expect($('.bio')).toBeVisible()
      new AcceptedSessions('#sandbox').load()
      expect($('.bio')).toBeHidden()