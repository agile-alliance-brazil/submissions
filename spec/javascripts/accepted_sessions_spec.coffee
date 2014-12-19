#=require spec_helper
#=require accepted_sessions

describe "AcceptedSessions", ->
  describe ".load", ->
    it "should hide all authors' bio", ->
      $('#konacha').append("<div id='sandbox'><div class='bio'></div></div>")
      expect($('.bio')).to.be.visible
      new AcceptedSessions('#sandbox').load()
      expect($('.bio')).to.be.hidden
