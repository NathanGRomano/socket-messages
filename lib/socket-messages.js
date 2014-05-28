var util = require('util')
  , events = require('events')
  ;

function SocketMessages () {
  var self = this;
  events.EventEmitter.call(this);
  this.onConnection = function (socket) {

  };
}

util.inherits(SocketMessages, events.EventEmitter);

SocketMessages.make = function () {
  return new SocketMessages();
}

SocketMessages.listen = function (io) {
  var socketMessages = this.make();
  socketMessages.attach(io);
  return socketMessages;
};

SocketMessages.prototype.attach = function (io) {
  io.on('connection', this.onConnection);
  return this;
};

SocketMessages.prototype.dettach = function (io) {
  io.removeListener('connection', this.onConnection);
  return this;
};

SocketMessages.prototype.actor = function (o, cb) {
  var type = typeof o;  
  if (arguments.length === 0) {
    if (!this._actor) {
      this._actor = function (socket, cb) {
        if (typeof cb === 'function') {
          cb(null, socket.id);
        }
      };
    }
    return this._actor;
  }
  else if (arguments.length === 1) {
    if (type === 'undefined' || !o) {
      return this;
    }
    if (type === 'function') {
      this._actor = o
    }
  }
  else if (arguments.length > 1) {
    if (type !== 'function') {
      if (!this._actor) {
        this._actor = function (socket, cb) {
          if (typeof cb === 'function') {
            cb(null, socket.id);
          }
        };
      }
      this._actor(o, cb);
    }
  }
  return this;
};

SocketMessages.prototype.target = function (o, p, cb) {
  var type = typeof o;  
  if (arguments.length === 0) {
    if (!this._target) {
      this._target = function (socket, params, cb) {
        if (typeof cb === 'function') {
          cb(null, socket.id);
        }
      };
    }
    return this._target;
  }
  else if (arguments.length === 1) {
    if (type === 'undefined' || !o) {
      return this;
    }
    if (type === 'function') {
      this._target = o
    }
  }
  else if (arguments.length > 2) {
    if (type !== 'function') {
      if (!this._target) {
        this._target = function (socket, params, cb) {
          if (typeof cb === 'function') {
            cb(null, socket.id);
          }
        };
      }
      this._target(o, p, cb);
    }
  }
  return this;
};

module.exports = SocketMessages;

