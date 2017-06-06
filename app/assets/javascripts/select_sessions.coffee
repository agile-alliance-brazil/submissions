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
        title: String,
        id: Number,
        duration: Number,
        authors: Array,
        track: String,
        audience: String,
        reviews: Array
      },
      template: """
<li class="sticky">
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
        :comment="review.comment"
        :confidence="review.confidence"
        :recommendation="review.recommendation_id">
      </review>
    </ul>
  </div>
</li>""",
      computed: {
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
        title: String,
        sessions: Array,
      },
      template: """
<li :class="outcomeClasses">
  <h2 class="title">{{ title }}</h2>
  <ul class="stickies">
    <sticky
      v-for="session in sessions"
      :key="session.id"
      :title="session.title"
      :id="session.id"
      :duration="session.duration"
      :authors="session.authors"
      :track="session.track"
      :audience="session.audience"
      :reviews="session.reviews">
    </sticky>
  </ul>
</div>
""",
      computed: {
        outcomeClasses: () -> 'outcome type_' + this.key
      }
    })
    Vue.component('outcome', outcome)

    component = Vue.extend({
      template: """
<ul class="board">
  <outcome
    v-for="outcome in outcomes"
    :key="outcome.id"
    :title="outcome.title"
    :sessions="sessionsFor(outcome)">
  </outcome>
</ul>""",
      methods: {
        sessionsFor: (outcome) ->
          this.sessions.filter((session, idx) -> (session.outcome || {id: 0}).id == outcome.id)
      }
      data: () ->
        {
          outcomes: [
            { id: 1, title: "Rejected"},
            { id: 0, title: "Undecided"},
            { id: 2, title: "Backup"},
            { id: 3, title: "Accepted"}
          ],
          sessions: [
            {
              title: 'very long test title',
              id: 1,
              duration: 50,
              authors: ['Jeferson Brizeno', 'Andreza Vitorina'],
              track: 'Você está certo disso?',
              audience: 'Iniciante',
              reviews: [
                { recommendation_id: 2, comment: 'Legal mas público pequeno', confidence: 3 },
                { recommendation_id: 4, comment: 'Porque é contestadora? Mudar trilha', confidence: 2 },
                { recommendation_id: 1, comment: 'Bom tópico de discussão', confidence: 4 },
              ]
            },
            {
              title: 'another very long test title',
              id: 2,
              duration: 110,
              authors: ['Hugo Corbucci'],
              track: 'É caindo que se aprende a levantar',
              audience: 'Iniciante avançado',
              reviews: [
                { recommendation_id: 3, comment: 'Vai saber o que esse cara quer', confidence: 1 },
                { recommendation_id: 2, comment: 'Agora vai!', confidence: 3 },
                { recommendation_id: 3, comment: '', confidence: 4 },
              ]
            }
          ],
        }
    })
    Vue.component('select-sessions', component)

    app = new Vue(el: '#vue_app', data: { currentView: 'select-sessions' })
  )()
)(jQuery)
