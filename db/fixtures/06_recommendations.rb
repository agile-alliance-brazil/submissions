# encoding: UTF-8
Recommendation.seed do |recommendation|
  recommendation.id = 1
  recommendation.name = 'strong_reject'
end

Recommendation.seed do |recommendation|
  recommendation.id = 2
  recommendation.name = 'weak_reject'
end

Recommendation.seed do |recommendation|
  recommendation.id = 3
  recommendation.name = 'weak_accept'
end

Recommendation.seed do |recommendation|
  recommendation.id = 4
  recommendation.name = 'strong_accept'
end
