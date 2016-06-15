underscore = require('underscore')
yasw = require './../../src/yasw_server'
ship = require './../../src/ship'

describe 'game tick', ->
  game_field = undefined
  beforeEach ->
    server= yasw.createServer({
      ship_rotation_rate: 2*Math.PI # radians/s
      tick_rate: 10                 # ticks/s
      fragment_life_time: 20
    })
    game = server.game
    game_field = game.game_field
    game_field.add_fragment(game,{game: game, outline: [[0,0],[0,5],[5,5],[5,0]]})
    game_field.add_fragment(game,{game: game, outline: [[2,2],[2,7],[7,7],[7,2]]})
    game.tick()

  it 'does not collide', ->
    expect(game_field.screen_objects().length).toEqual(2)


describe "game#tick" , ->
  server= undefined
  heading_change= undefined
  sent_data = undefined
  ships = undefined
  fragment = undefined
  dead_fragment = undefined

  beforeEach ->
    server= yasw.createServer({
      ship_rotation_rate: 2*Math.PI # radians/s
      tick_rate: 10                 # ticks/s
      fragment_life_time: 20
    })
    heading_change= server.ship_rotation_rate/server.tick_rate;
    ships=[]
    ships.push server.game.add_ship({rotation:  0, heading:          0, points: [[5, 0]], position: [10, 10]})
    ships.push server.game.add_ship({rotation:  0, heading:  Math.PI/2, points: [[3, 0]], position: [20, 20]})
    ships.push server.game.add_ship({rotation:  1, heading:          0, points: [[5, 0]], position: [30, 30]})
    ships.push server.game.add_ship({rotation: -1, heading:  Math.PI/2, points: [[3, 0]], position: [105, 100]})

    fragment = ships[0].explode()[0]
    dead_fragment= ships[1].explode()[0]
    dead_fragment.life_left = 0

    fake_socket=
      send: (data) ->
        sent_data = data

    player= server.game.add_player('player_id');
    player.socket= fake_socket;

    server.game.tick()

  it 'updates fragments', ->
    expect(fragment.life_left).toBeCloseTo(3 - 1/server.tick_rate, 6)

  it 'does not kill the live fragment', ->
    expect(server.game.game_field.screen_objects()).toContain(fragment)

  it 'has no dead fragments', ->
    expect(server.game.game_field.screen_objects()).not.toContain(dead_fragment)

  afterEach ->
    server= null