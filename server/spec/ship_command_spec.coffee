yasw = require './../../src/yasw_server'
engine_client = require 'engine.io-client'
ship = require './../../src/ship'

describe 'the server, when asked for ship data ', ->
  server= undefined
  beforeEach ->
    server= yasw.createServer()
    server.game.add_player('0.5328')
    server.listen(3000)

  setup_ship = (socket, init_ship, test, done) ->
    socket.on 'error', (e) ->
      console.log("Error: #{e}")
      test.fail("Socket error: #{e}")
      done()
    socket.on 'upgradeError', (e)->
      test.fail("Upgrade error: #{e}")
      done()
    if init_ship
      init_ship();

  check_angular_velocity = (ship_command, expected_angular_velocity, server, test, init_ship, done) ->
    spyOn(server, 'socket_cookies').andReturn("yasw_player_id=0.5328")
    socket = engine_client('ws://localhost:3000', transports: ['websocket'])
    socket.on 'open', ->
      setup_ship(socket, init_ship, test, done)
      socket.send JSON.stringify({'command': ship_command}) , ->
        setTimeout (->
          expect(server.game.game_field.screen_objects()[0].angular_velocity).toEqual(expected_angular_velocity)
          done()
        ),50

  check_acceleration = (ship_command, expected_acceleration, server, test, init_ship, done) ->
    spyOn(server, 'socket_cookies').andReturn("yasw_player_id=0.5328")
    socket = engine_client('ws://localhost:3000', transports: ['websocket'])
    socket.on 'open', ->
      setup_ship(socket, init_ship, test, done)
      socket.send JSON.stringify({'command': ship_command}) , ->
        setTimeout (->
          expect(server.game.game_field.screen_objects()[0].acceleration).toEqual(expected_acceleration)
          done()
        ),50

  check_fire = (ship_command,  server, test, init_ship, done) ->
    spyOn(server, 'socket_cookies').andReturn("yasw_player_id=0.5328")
    socket = engine_client('ws://localhost:3000', transports: ['websocket'])
    socket.on 'open', ->
      setup_ship(socket, init_ship, test, done)
      spyOn(server.game.game_field.screen_objects()[0],'fire')
      socket.send JSON.stringify({'command': ship_command}) , ->
        setTimeout (->
          expect(server.game.game_field.screen_objects()[0].fire).toHaveBeenCalled()
          done()
        ),50

  check_clone = (server, test, done) ->
    spyOn(server, 'socket_cookies').andReturn("yasw_player_id=0.5328")
    socket = engine_client('ws://localhost:3000', transports: ['websocket'])
    socket.on 'open', ->
      setup_ship(socket, null, test, done)
      socket.send JSON.stringify({'command': 'clone'}) , ->
        setTimeout (->
          expect(server.game.game_field.screen_objects().length).toEqual(2)
          done()
        ),50

  it 'starts with no ships', () ->
    expect(server.game.game_field.screen_objects().length).toEqual(0)

  it 'sets ship negative angular_velocity on rotate_left', (done) ->
    check_angular_velocity "rotate_left", -ship.Ship.rotation_rate, server, this, null, done

  it 'sets ship postive angular_velocity on rotate_right', (done) ->
    check_angular_velocity "rotate_right", ship.Ship.rotation_rate, server, this, null, done

  it 'sets ship no angular_velocity on rotate_stop', (done) ->
    set_angular_velocity = ->
      server.game.game_field.screen_objects()[0].angular_velocity = 1
    check_angular_velocity "rotate_stop", 0, server, this, set_angular_velocity, done

  it 'sets acceleration on thrust_on', (done) ->
    check_acceleration "thrust_on", 30, server, this, null, done

  it 'sets no acceleration on thrust_off', (done) ->
    set_acceleration= ->
      server.game.game_field.screen_objects()[0].acceleration= 1
    check_acceleration "thrust_off", 0, server, this, set_acceleration, done

  it 'fires a bullet on command', (done) ->
    check_fire('fire',server,this,null, done)

  it 'clones the ship on command', (done) ->
    check_clone(server, this, done)

  afterEach ->
    server.shutdown()
