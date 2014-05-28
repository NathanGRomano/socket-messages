var util = require('util')
  , events = require('events')
  ;

function SocketMessages () {
  var self = this;
  events.EventEmitter.call(this);

  this.onConnection = function (socket) {

    function onAction (name) {
      if (socket.listeners(name).indexOf(self.onMessage) < 0) {
        socket.on(name, function () {
          var args = Array.prototype.slice.call(arguments);
          self.onMessage(socket, args);
        });
      }
    }
   
    self.on('action', onAction);

    if (self.actions()) {
      self.actions().forEach(onAction);
    }

    socket.on('disconnect', function () {
      self.removeListener('action', onAction);
      self.actions().forEach(function (name) {
        socket.removeAllListeners(name);
      });
    });

  };

  this.onMessage = function (socket, args) {
    console.log('socket', socket, 'args', args);
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

SocketMessages.prototype.exchange = function (o) {
  if (arguments.length === 0) {
    if (!this._exchange) {
      this._exchange = new events.EventEmitter();
    }
    return this._exchange;
  }
  else {
    this._exchange = o;
  }
  return this;
};

SocketMessages.prototype.action = function (name) {
  if (typeof name === 'string' && this.actions().indexOf(name) < 0) {
    this.actions().push(name)
    this.emit('action', name);
  }
  return this;
};

SocketMessages.prototype.actions = function () {
  if (!this._actions) {
    this._actions = [];
  }
  return this._actions;
};

module.exports = SocketMessages;

