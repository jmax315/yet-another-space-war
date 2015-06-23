game = require './../../src/game'
ship = require './../../src/ship'
vector = require './../../src/vector'

describe 'Ship fires a bullet', ->
  it 'creates bullet', ->
    the_game = new game.Game
      ship_rotation_rate: 1
      tick_rate: 1
      acceleration_rate: 1
      field_size: new vector.Vector([900,900])

    the_ship = the_game.add_ship({velocity: [50, 50], heading: Math.PI/4})
    bullet = the_ship.fire()

    expect(bullet.velocity.x()).toBeCloseTo(50 + 10/Math.sqrt(2), 1e-6)
    expect(bullet.velocity.y()).toBeCloseTo(50 + 10/Math.sqrt(2), 1e-6)
    
