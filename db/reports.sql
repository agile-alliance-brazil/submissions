-- Reviews Report
select    reviews.type,
          sessions.id,
          sessions.title,
          first_author.first_name,
          first_author.last_name,
          second_author.first_name,
          second_author.last_name,
          strong_accepts.cnt AS strong_accept,
          weak_accepts.cnt AS weak_accept,
          weak_rejects.cnt AS weak_reject,
          strong_rejects.cnt AS strong_reject,
          reviewer.first_name,
          reviewer.last_name,
          tracks.title,
          reviews.proposal_track,
          session_types.title,
          reviews.proposal_type,
          audience_levels.title,
          reviews.proposal_level,
          sessions.audience_limit,
          reviews.proposal_limit,
          sessions.duration_mins,
          reviews.proposal_duration,
          reviews.author_agile_xp_rating_id,
          reviews.author_proposal_xp_rating_id,
          reviews.proposal_abstract,
          reviews.proposal_quality_rating_id,
          reviews.proposal_relevance_rating_id,
          reviews.recommendation_id,
          reviews.justification,
          reviews.reviewer_confidence_rating_id,
          reviews.comments_to_organizers,
          reviews.comments_to_authors
from      sessions
inner join
          users AS first_author
          on first_author.id = sessions.author_id
left outer join
          users AS second_author
          on second_author.id = sessions.second_author_id
inner join
          tracks
          on tracks.id = sessions.track_id
inner join
          session_types
          on session_types.id = sessions.session_type_id
inner join
          audience_levels
          on audience_levels.id = sessions.audience_level_id
left outer join (
            SELECT session_id, count(*) AS cnt
            FROM reviews
            WHERE recommendation_id = 4
            GROUP BY session_id
          ) AS strong_accepts
          ON strong_accepts.session_id = sessions.id
left outer join (
            SELECT session_id, count(*) AS cnt
            FROM reviews
            WHERE recommendation_id = 3
            GROUP BY session_id
          ) AS weak_accepts
          ON weak_accepts.session_id = sessions.id
left outer join (
            SELECT session_id, count(*) AS cnt
            FROM reviews
            WHERE recommendation_id = 2
            GROUP BY session_id
          ) AS weak_rejects
          ON weak_rejects.session_id = sessions.id
left outer join (
            SELECT session_id, count(*) AS cnt
            FROM reviews
            WHERE recommendation_id = 1
            GROUP BY session_id
          ) AS strong_rejects
          ON strong_rejects.session_id = sessions.id
inner join reviews ON reviews.session_id = sessions.id
inner join
          users AS reviewer
          on reviewer.id = reviews.reviewer_id
where     sessions.state <> 'cancelled'
          AND sessions.conference_id = 3
order by sessions.id, reviews.type DESC

-- Reviewer experience on track
select    reviewer.first_name,
          reviewer.last_name,
          preferences.accepted,
          tracks.title,
          audience_levels.title
from      reviewers
inner join
          users AS reviewer
          on reviewer.id = reviewers.user_id
inner join
          preferences
          on reviewer.id = preferences.reviewer_id
left outer join
          tracks
          on tracks.id = preferences.track_id
left outer join
          audience_levels
          on audience_levels.id = preferences.audience_level_id
where     conference_id = 2
order by reviewer.first_name, reviewer.last_name

-- Cleanup prod data for testing e-mails on staging
delete from comments where commentable_type = 'Session' AND commentable_id NOT IN (288,285,303,153,325,318,280);
delete from review_decisions where session_id NOT IN (288,285,303,153,325,318,280);
delete from reviews where session_id NOT IN (288,285,303,153,325,318,280);
delete from sessions where id NOT IN (288,285,303,153,325,318,280);
update users set email = 'dtsato@hotmail.com' where id = 71;
update users set email = 'danilo@dtsato.com' where id = 56;

-- Find sessions that were accepted, but withdrawn by authors
select * from review_decisions
inner join sessions on review_decisions.session_id = sessions.id
where outcome_id = 1 and sessions.state = 'rejected' and conference_id = 2