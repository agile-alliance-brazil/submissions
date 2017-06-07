# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#= require jquery

(($) ->
  $(document).ready(() ->
    acronymize = (text) ->
      text.replace(/^\w{1,2}(\W)|(\W)\w{1,2}(\W)|(\W)\w{1,2}$/g, '$1$2').
        replace(/(\w)(\w|[^\x00-\x7F])*/g, '$1').
        replace(/\W/g, '').
        toUpperCase()

    review = Vue.extend({
      props: {
        comment: String,
        confidence: Number,
        recommendation: Number,
      },
      template: """
<li class="review clearfix">
  <div :class="recommendationClasses">
    <span v-if="strongAccept">✔✔</span>
    <span v-if="weakAccept">✔</span>
    <span v-if="weakReject">✘</span>
    <span v-if="strongReject">✘✘</span>
  </div>
  <p class="comment">{{ comment }}</p>
  <div :class="confidenceClasses">
    <span v-if="veryConfident">++</span>
    <span v-if="confident">+</span>
    <span v-if="unconfident">-</span>
    <span v-if="veryUnconfident">--</span>
  </div>
</li>""",
      computed: {
        recommendationClasses: () -> "recommendation type_" + this.recommendation
        strongAccept: () -> this.recommendation == 1
        weakAccept: () -> this.recommendation == 2
        weakReject: () -> this.recommendation == 3
        strongReject: () -> this.recommendation == 4
        confidenceClasses: () -> "confidence type_" + this.confidence
        veryConfident: () -> this.confidence == 1
        confident: () -> this.confidence == 2
        unconfident: () -> this.confidence == 3
        veryUnconfident: () -> this.confidence == 4
      }
    })
    Vue.component('review', review)

    sticky = Vue.extend({
      props: {
        session: Object
      },
      template: """
<li class="sticky" :data-session-id="id" :id="htmlId">
  <h3 class="title">
    <abbr :title="title" v-if="abbrTitle">{{ limitedTitle }}</abbr>
    <span v-else>{{ title }}</span>
  </h3>
  <div class="grid-12 p-t-5">
    <span class="id col col-2">ID {{ id }}</span>
    <span class="authors col col-8">{{ authorNames }}</span>
    <span class="duration col col-2">{{ duration }}'</span>
  </div>
  <div class="grid-12 p-t-5">
    <div class="col col-2 meta">
      <abbr class="track" :title="track">{{ trackAcronym }}</abbr>
      <abbr class="audience" :title="audience">{{ audienceAcronym }}</abbr>
    </div>
    <ul class="col col-10 reviews">
      <review
        v-for="review in reviews"
        :key="review.recommendation_id"
        :comment="review.comments_to_organizers"
        :confidence="review.reviewer_confidence_rating_id"
        :recommendation="review.recommendation_id">
      </review>
    </ul>
  </div>
</li>""",
      computed: {
        title: () -> this.session.title,
        id: () -> this.session.id,
        duration: () -> this.session.duration,
        authors: () -> this.session.authors.map((a) -> "#{a.first_name} #{a.last_name}"),
        track: () -> this.session.track.title,
        audience: () -> this.session.audience_level.title,
        reviews: () -> this.session.final_reviews,
        htmlId: () -> 'session_' + this.id,
        limitedTitle: () ->
          v = this.title + ''
          if v.length > 20
            l = v.length
            v = v.substring(0, 10) + '...' + v.substring(l - 8, l)
          v
        abbrTitle: () -> (this.title + '').length > 20
        authorNames: () -> this.authors.map((v, idx) -> v[0]+'.'+v.substring(v.trim().lastIndexOf(' '))).join(' & ')
        trackAcronym: () -> acronymize(this.track)
        audienceAcronym: () -> acronymize(this.audience)
      }
    })
    Vue.component('sticky', sticky)

    outcome = Vue.extend({
      props: {
        outcome: Object,
        outcomes: Object,
        sessions: Array,
        allSessions: Object
      },
      template: """
<li :class="outcomeClasses" :id="htmlId">
  <h2 class="title">{{ title }}</h2>
  <draggable v-model="sessions" class="stickies" element="ul" :options="options" @add="addSession" :data-outcome-id="id">
    <sticky
      v-for="session in sessions"
      :key="session.id"
      :session="session">
    </sticky>
  </draggable>
</li>
""",
      methods: {
        addSession: (event) ->
          newOutcomeId = event.to.dataset.outcomeId
          newOutcome = this.outcomes[newOutcomeId]
          sessionId = event.item.dataset.sessionId
          session = this.allSessions[sessionId]
          if session
            session.review_decision ||= {}
            session.review_decision.outcome = newOutcome
      },
      computed: {
        title: () -> this.outcome.title,
        id: () -> this.outcome.id,
        htmlId: () -> 'outcome_' + this.id
        outcomeClasses: () -> 'outcome type_' + this.id,
        options: () ->
          {
            dragClass: '.sticky',
            group: 'sessions'
          }
      }
    })
    Vue.component('outcome', outcome)


    component = Vue.extend({
      template: """
<ul class="board">
  <outcome
    v-for="outcome in outcomes"
    :key="outcome.id"
    :outcome="outcome"
    :outcomes="outcomesMap"
    :sessions="sessionsFor(outcome)"
    :allSessions="sessionsMap">
  </outcome>
</ul>
""",
      computed: {
        outcomesMap: () ->
          this.outcomes.reduce(((acc, item) -> acc[item.id] = item; acc), {})
        sessionsMap: () ->
          this.sessions.reduce(((acc, item) -> acc[item.id] = item; acc), {})
      },
      methods: {
        sessionsFor: (outcome) ->
          ss = this.sessions.filter((session, idx) -> ((session.review_decision || {}).outcome || {id: 0}).id == outcome.id)
          reviews_score = (reviews) ->
             reviews.reduce(((acc, r) -> acc + r.recommendation_id), 0)
          ss.sort((a, b) -> reviews_score(a.final_reviews) - reviews_score(b.final_reviews))
      },
      data: () -> { outcomes: [], sessions: [] },
      mounted: () ->
        self = this
        $.ajax({
          url: 'outcomes.json',
          method: 'GET',
          success: (data) ->
            remoteOutcomes = data || []
            remoteOutcomes.splice(1, 0, {id: 0, title: '?'})
            self.outcomes = remoteOutcomes
          error: (error) -> console.log(JSON.stringify(error))
        })
        $.ajax({
          url: 'organizer_sessions.json',
          method: 'GET',
          success: (data) ->
            self.sessions = data || []
          error: (error) -> console.log(JSON.stringify(error))
        })
    })
    Vue.component('select-sessions', component)

    app = new Vue(el: '#vue_app', data: { currentView: 'select-sessions' })
  )()
)(jQuery)
