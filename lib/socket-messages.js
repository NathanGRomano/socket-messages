var util = require('util')
  , events = require('events')
  ;

function SocketMessages (io) {
  events.EventEmitter.call(this);
  this.io = io;
}

util.inherits(SocketMessages, events.EventEmitter);

SocketMessages.listen = function (io) {
  return new SocketMessages(io);
};

module.exports = SocketMessages;

