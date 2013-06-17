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

# Agile Brazil 2013
#Sala 3
Room.seed do |room|
  room.id = 8
  room.name = 'Praça dos 3 Poderes'
  room.capacity = 500
  room.conference_id = 4
end

#Sala 2
Room.seed do |room|
  room.id = 9
  room.name = 'Palácio da Alvorada'
  room.capacity = 300
  room.conference_id = 4
end

#Sala G+H
Room.seed do |room|
  room.id = 10
  room.name = 'Ponte JK'
  room.capacity = 144
  room.conference_id = 4
end

#Sala E+F
Room.seed do |room|
  room.id = 11
  room.name = 'Catedral'
  room.capacity = 106
  room.conference_id = 4
end

#Sala B+C+D
Room.seed do |room|
  room.id = 12
  room.name = 'Concha Acústica'
  room.capacity = 70
  room.conference_id = 4
end

#Sala N
Room.seed do |room|
  room.id = 13
  room.name = 'Parque da Cidade'
  room.capacity = 90
  room.conference_id = 4
end
