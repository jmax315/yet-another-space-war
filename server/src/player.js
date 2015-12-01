exports.Player= function() {
  this._score= 0;
};

exports.Player.prototype.bump_score = function() {
  this._score++;
};

exports.Player.prototype.on_message = function(message) {
  if (this.ship) {
    this.ship.on_message(message);
  }
};
