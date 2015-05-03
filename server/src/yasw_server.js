var http = require("http");
var engine_io = require('engine.io');
var fs= require('fs');
var url= require('url');
var underscore= require('underscore');
var ship= require('./ship');

exports.createServer= function(parameters) {
  var yasw_server= {};
  var http_server;

  yasw_server.ship_rotation_rate = (parameters && parameters.ship_rotation_rate) || Math.PI;
  yasw_server.tick_rate = (parameters && parameters.tick_rate) || 1;
  yasw_server.debug= (parameters && parameters.debug) || false;

  yasw_server.ships= [];
  yasw_server.add_ship= function(new_ship_data) {
    var new_ship= new ship.Ship(new_ship_data);
    // DEBUG
    if (yasw_server.debug) {
      console.log("server#new_ship:", new_ship);
    }

    yasw_server.ships.push(new_ship);
  };

  yasw_server.tick= function() {
    underscore.each(yasw_server.ships,
           function(ship) {
             ship.heading += yasw_server.ship_rotation_rate/yasw_server.tick_rate * ship.rotation;
           });

    if(yasw_server.ships[0] ){
      var the_ship = yasw_server.ships[0];
      var ship_outline = the_ship.outline();
      if (the_ship.socket) {
        the_ship.socket.send("{\"0\": " + JSON.stringify(ship_outline) + " }");
      }
    }
  };
  setInterval(yasw_server.tick, 1000/yasw_server.tick_rate);
 
  yasw_server.on_new_connection= function(socket) {
    console.log("websocket connect from " + socket.remoteAddress);

    socket.send("0");
    yasw_server.add_ship(
      new ship.Ship({
        rotation: 0,
        points: [[4,-2], [-7,-4], [3,6]],
        heading: 0,
        socket: socket,
        location: [100,100],
        debug: yasw_server.debug
      })
    );


    socket.on('message', function(data) {
      var message= JSON.parse(data);

      var ship= yasw_server.ships[0];

      switch(message.command) {
      case 'rotate_left':
        yasw_server.ships[0].rotation = -1;
        break;
      case 'rotate_right':
        yasw_server.ships[0].rotation = 1;
        break;
      case 'rotate_stop':
        yasw_server.ships[0].rotation = 0;
        break;
      }
    });
  };

  yasw_server.listen= function(port) {
    http_server= http.createServer(function(request, response) {
      var filename= url.parse(request.url).pathname;
      if (filename == '/')
        filename= "/index.html";
      yasw_server.static_page(filename, response);
    });
    
    var listener = http_server.listen(port);
    var engine_server = engine_io.attach(listener);
    engine_server.on('connection', yasw_server.on_new_connection);
    console.log('listen on port ' + port);
  };

  yasw_server.shutdown= function() {
    http_server.close();
    http_server= null;
  };

  yasw_server.static_page= function(page, response) {
    var filename= "public" + page;
    var file_extension= page.split(".").pop();
    var read_stream= fs.createReadStream(filename);
    read_stream.on('open', function() {
      if (file_extension === "js")
        response.writeHead(200, {"Content-Type": "text/javascript"});
      else
        response.writeHead(200, {"Content-Type": "text/html"});
      read_stream.pipe(response);
    });
    read_stream.on('error', function() {
      response.writeHead(404);
      response.end();
    });
  };

  return yasw_server;
};
