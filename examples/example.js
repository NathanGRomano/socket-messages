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
  this.calls = this.calls || 0;
  console.log('message', JSON.stringify(message));
  if (++this.calls > 2) process.exit(0);
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
     console.log('the args', args);
     var target = args.shift();
     console.log('the target', target);
    cb(null, target); 
  })
  .exchange(exchange)
  .action('say')
  .autoPropagate(true);

setTimeout(function () {

  console.log('connecting...');

  /*
   * initialize the client
   */
  var socket = require('socket.io-client')('http://localhost:3000');

  socket.on('connect', function () {
    socket.emit('say', 'you', 'hello, world!');
    socket.emit('other action', 'ok');
  });

},1000);
