/*
 * Initialize the server, io, and socketMessages
 */
var io = require('socket.io')();
io.listen(3000);

/*
 * simulate our exchange
 */

var exchange = new (require('events')).EventEmitter();
exchange.on('message', function (message) {
  console.log('message', message);
  process.exit();
});

/*
 * configure our instance
 */
require('../.')
  .listen(io)
  .actor(function (socket, cb) {
    cb(null, socket.id);
  })
  .target(function (socket, args, cb) {
     var target = args.shift();
     console.log('args', args);
     console.log('target', target);
    cb(null, args.shift()); 
  })
  .exchange(exchange)
  .action('test');

setTimeout(function () {

  console.log('connecting...');

  /*
   * initialize the client
   */
  var socket = require('socket.io-client')('http://localhost:3000');

  socket.on('connect', function () {
    socket.emit('test', 'hello, world!');
  });

},1000);
