var underscore= require('underscore');
var ship=require('./ship');
var bullet=require('./bullet');
var vector=require('./vector');

exports.Game=function(initial_state) {
  var self = this;
  self.field_size = new vector.Vector([800,600]);
  self.bullet_speed= initial_state.bullet_speed || 7;

  self.add_screen_object= function(new_screen_object) {
    self.screen_objects.push(new_screen_object);
    return new_screen_object;
  };

  self.add_ship = function(parameters) {
    var defaultState = {
      game: self,
      rotation: 0,
      points: [[-10, 10], [20, 0], [-10, -10], [0, 0]],
      heading: 0,
      position: [0, 0]
    };

    if (parameters !== undefined)
      underscore.extend(defaultState ,parameters);

    return self.add_screen_object(new ship.Ship(defaultState));
  };

  self.add_bullet= function(parameters){
    var defaultState = {
      game: self,
      rotation: 0,
      points: [[-1, -1], [-1, 1], [1, 1], [1, -1]],
      position: [0, 0]
    };

    if (parameters !== undefined)
      underscore.extend(defaultState ,parameters);

    return self.add_screen_object(new bullet.Bullet(defaultState));
  };

  function each_screen_object(callback_function) {
    underscore.each(self.screen_objects, callback_function);
  }

  function update_screen_objects() {
    each_screen_object(
      function(screen_object) {
        screen_object.update(
          initial_state.ship_rotation_rate,
          initial_state.tick_rate,
          initial_state.acceleration_rate);
      });
  }

  function game_board() {
    var outlines = {};
    each_screen_object(
      function(screen_object, id) {
        outlines[id] = screen_object.outline();
      });
    return JSON.stringify(outlines);
  }

  function send_game_board(new_board) {
    each_screen_object(
      function(ship) { if (ship.socket) ship.socket.send(new_board); });
  }

  self.tick= function() {
    update_screen_objects();
    send_game_board(game_board());
  };

  if (initial_state.tick_rate!==0)
    setInterval(self.tick, 1000/initial_state.tick_rate);

  self.screen_objects=[];
};
