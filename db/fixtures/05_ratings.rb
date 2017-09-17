# frozen_string_literal: true

Rating.seed do |rating|
  rating.id = 1
  rating.title = 'rating.none.title'
end

Rating.seed do |rating|
  rating.id = 2
  rating.title = 'rating.low.title'
end

Rating.seed do |rating|
  rating.id = 3
  rating.title = 'rating.medium.title'
end

Rating.seed do |rating|
  rating.id = 4
  rating.title = 'rating.high.title'
end
