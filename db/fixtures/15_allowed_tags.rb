# encoding: UTF-8
# frozen_string_literal: true

tags = ActsAsTaggableOn::Tag.where(name: ['tags.continuous_improvement', 'tags.learning', 'tags.culture', 'tags.ideas',
                                          'tags.motivation', 'tags.opportunities', 'tags.teams', 'tags.strategies', 'tags.patterns',
                                          'tags.processes', 'tags.tecniques', 'tags.legacy', 'tags.implementation', 'tags.planning',
                                          'tags.refactoring', 'tags.customer_relationship', 'tags.coaching', 'tags.commitment', 'tags.evolution',
                                          'tags.success', 'tags.skill', 'tags.requirements', 'tags.ux', 'tags.failure', 'tags.business',
                                          'tags.continuous_deploy', 'tags.creation', 'tags.startup', 'tags.restrictions', 'tags.metrics',
                                          'tags.code_review', 'tags.continuous_integration', 'tags.emergent_design', 'tags.tdd',
                                          'tags.pair_programming', 'tags.tests', 'tags.automation', 'tags.risks', 'tags.estimates', 'tags.front',
                                          'tags.visualization', 'tags.recovery']).map(&:id)
conferences = [5, 6]
conferences.each do |id|
  tags.each do |tag_id|
    ActsAsTaggableOn::Tagging.seed(:tag_id, :taggable_id, :taggable_type) do |t|
      t.tag_id = tag_id
      t.taggable_id = id
      t.taggable_type = 'Conference'
      t.context = 'tags'
    end
  end
end
tags = ActsAsTaggableOn::Tag.where(name: ['tags.analysis', 'tags.learning', 'tags.architecture', 'tags.automation', 'tags.self_organizing',
                                          'tags.big_data', 'tags.coaching', 'tags.legacy', 'tags.continuous', 'tags.culture', 'tags.deploy',
                                          'tags.development', 'tags.design', 'tags.devops', 'tags.disruptive', 'tags.emergent', 'tags.empowering',
                                          'tags.entrepreneurship', 'tags.teaching', 'tags.delivery', 'tags.scale', 'tags.estimates',
                                          'tags.strategies', 'tags.facilitation', 'tags.failure', 'tags.front', 'tags.management',
                                          'tags.incremental', 'tags.information', 'tags.integração', 'tags.artificial_intelligence', 'tags.iot',
                                          'tags.kanban', 'tags.lean', 'tags.leadership', 'tags.improvement', 'tags.mentoring', 'tags.market',
                                          'tags.goals', 'tags.method', 'tags.metrics', 'tags.motivation', 'tags.mvp', 'tags.business',
                                          'tags.patterns', 'tags.planning', 'tags.principles_and_values', 'tags.processes', 'tags.product',
                                          'tags.project', 'tags.psychology', 'tags.quality', 'tags.refactoring', 'tags.experience_report',
                                          'tags.requirements', 'tags.restrictions', 'tags.code_review', 'tags.risks', 'tags.safe', 'tags.scrum',
                                          'tags.startup', 'tags.success', 'tags.tecniques', 'tags.trends', 'tags.tests', 'tags.teams', 'tags.ux',
                                          'tags.hypothesis_validation', 'tags.value', 'tags.visualization', 'tags.xp']).map(&:id)
conferences = [Conference.where(year: 2016).first.try(:id)].compact
conferences.each do |id|
  tags.each do |tag_id|
    ActsAsTaggableOn::Tagging.seed(:tag_id, :taggable_id, :taggable_type) do |t|
      t.tag_id = tag_id
      t.taggable_id = id
      t.taggable_type = 'Conference'
      t.context = 'tags'
    end
  end
end
tags = ActsAsTaggableOn::Tag.where(name: ['tags.analysis', 'tags.learning', 'tags.architecture', 'tags.automation', 'tags.self_organizing',
                                          'tags.big_data', 'tags.coaching', 'tags.legacy', 'tags.continuous', 'tags.culture', 'tags.deploy',
                                          'tags.development', 'tags.design', 'tags.devops', 'tags.disruptive', 'tags.emergent', 'tags.empowering',
                                          'tags.entrepreneurship', 'tags.teaching', 'tags.delivery', 'tags.scale', 'tags.estimates',
                                          'tags.strategies', 'tags.evolution', 'tags.facilitation', 'tags.failure', 'tags.front',
                                          'tags.incremental', 'tags.information', 'tags.integração', 'tags.artificial_intelligence', 'tags.iot',
                                          'tags.innovation', 'tags.kanban', 'tags.lean', 'tags.leadership', 'tags.improvement', 'tags.mentoring',
                                          'tags.market', 'tags.goals', 'tags.method', 'tags.metrics', 'tags.motivation', 'tags.mvp', 'tags.business',
                                          'tags.portfolio', 'tags.patterns', 'tags.planning', 'tags.principles_and_values', 'tags.processes',
                                          'tags.product', 'tags.project', 'tags.psychology', 'tags.quality', 'tags.refactoring',
                                          'tags.experience_report', 'tags.requirements', 'tags.restrictions', 'tags.code_review', 'tags.risks',
                                          'tags.safe', 'tags.scrum', 'tags.startup', 'tags.success', 'tags.tecniques', 'tags.trends', 'tags.tests',
                                          'tags.teams', 'tags.ux', 'tags.hypothesis_validation', 'tags.value', 'tags.visualization', 'tags.xp']).map(&:id)
conferences = [Conference.where(year: 2017).first.try(:id)].compact
conferences.each do |id|
  tags.each do |tag_id|
    ActsAsTaggableOn::Tagging.seed(:tag_id, :taggable_id, :taggable_type) do |t|
      t.tag_id = tag_id
      t.taggable_id = id
      t.taggable_type = 'Conference'
      t.context = 'tags'
    end
  end
end
