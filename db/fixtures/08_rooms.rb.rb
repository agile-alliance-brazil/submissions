# encoding: UTF-8
Room.seed do |room|
  room.id = 1
  room.name = 'São Paulo'
  room.capacity = 400
  room.conference_id = 3
end

Room.seed do |room|
  room.id = 2
  room.name = 'Brasil'
  room.capacity = 400
  room.conference_id = 3
end

Room.seed do |room|
  room.id = 3
  room.name = 'Rio de Janeiro'
  room.capacity = 200
  room.conference_id = 3
end

Room.seed do |room|
  room.id = 4
  room.name = 'Minas Gerais'
  room.capacity = 200
  room.conference_id = 3
end

Room.seed do |room|
  room.id = 5
  room.name = 'Paraná'
  room.capacity = 90
  room.conference_id = 3
end

Room.seed do |room|
  room.id = 6
  room.name = 'Pernambuco - WBMA'
  room.capacity = 80
  room.conference_id = 3
end

Room.seed do |room|
  room.id = 7
  room.name = "Pernambuco - Executive Summit"
  room.capacity = 80
  room.conference_id = 3
end