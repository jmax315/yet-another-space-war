yasw = require './../../src/yasw_server'
ship = require './../../src/ship'

describe "ship#outline" , ->
  server= undefined
  on_message_callback = undefined
  fake_socket = undefined

  beforeEach ->
    fake_socket =
      send: ->
      on: (message, callback) ->
        on_message_callback = callback

    server= yasw.createServer()
    server.game.add_ship({game: server.game, heading: -Math.PI/2, points: [[10, 0]]})
    server.game.add_ship({game: server.game, heading:          0, points: [[5, 0]]})
    server.game.add_ship({game: server.game, heading:  Math.PI/2, points: [[3, 0]]})
    server.on_new_connection(fake_socket)
    on_message_callback(JSON.stringify({command: 'rotate_left'}));

  it 'rotates the correct ship', ->
    expect(fake_socket.ship.rotation).toEqual(-1)

  afterEach ->
    server= null
