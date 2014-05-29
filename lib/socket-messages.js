var util = require('util')
  , events = require('events')
  ;

/**
 * Produces and publishes socket messages
 */

function SocketMessages () {
  var self = this;
  events.EventEmitter.call(this);

  /**
   * When a socket is accepted
   *
   * @param {object} socket
   */

  this.onConnection = function (socket) {

    /**
     * This is used to add listeners to sockets when the SocketMessages.prototype.action()
     * method is invoked
     *
     * @param {string} name
     */

    function onAction (name) {
      if (socket.listeners(name).indexOf(self.onMessage) < 0) {
        socket.on(name, function () {
          var args = Array.prototype.slice.call(arguments);
          self.onMessage(socket, [name].concat(args));
        });
      }
    }
   
    self.on('action', onAction);

    /*
     * take the current actions and set up handlers for them
     */

    if (self.actions()) {
      self.actions().forEach(onAction);
    }


    /*
     * when we disconnect we want to remove the handlers and the onAction
     * method
     */

    socket.on('disconnect', function () {
      self.removeListener('action', onAction);
      self.actions().forEach(function (name) {
        socket.removeAllListeners(name);
      });
    });

  };

  /*
   * Called when we receive data from the socket
   * It will build up the actor, target, and content
   * to produce a json object that will be published
   * onto an exchange / event emitter
   */

  this.onMessage = function (socket, args) {
    var event = { created: new Date(), action:args.shift() };
    self.actor(socket, function (err, actor) {
      if (err) {
        return self.emit('error', err, socket, args);
      }
      event.actor = actor;
      self.target(socket, args, function (err, target) {
        if (err) {
          return self.emit('error', err, socket, args);
        }
        event.target = target;
        event.content = args;
        self.exchange().emit('message', event);
      });
    });
  };

}

util.inherits(SocketMessages, events.EventEmitter);

/**
 * @return SocketMessages
 */

SocketMessages.make = function () {
  return new SocketMessages();
};

/**
 * Creates a new instance and has it listen to "io"
 *
 * @param {object} io
 * @return SocketMessages
 */

SocketMessages.listen = function (io) {
  var socketMessages = this.make();
  socketMessages.attach(io);
  return socketMessages;
};

/**
 * Attaches our #onConnection method to the io object
 *
 * @param {object} io
 * @return SocketMessages
 */

SocketMessages.prototype.attach = function (io) {
  io.on('connection', this.onConnection);
  return this;
};

/**
 * Dettaches our #onConnection method from the io object
 *
 * @param {object} io
 * @return SocketMessages
 */

SocketMessages.prototype.dettach = function (io) {
  io.removeListener('connection', this.onConnection);
  return this;
};

/**
 * Either sets the actor query method or invokes it
 *
 * Set
 *
 * @param {Function} o
 *
 * Invoke
 *
 * @param {Object} o The socket
 * @param {Function} cb
 *
 * @return SocketMessages
 */

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

/**
 * Either sets the target query method or invokes it
 *
 * Set
 *
 * @param {Function} o
 *
 * Invoke
 *
 * @param {Object} o The socket
 * @param {Array} p The arguments emitted from the socket
 * @param {Function} cb
 *
 * @return SocketMessages
 */

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

/**
 * Sets or Gets the exchange.  If it doesn't exist it will initialize it
 *
 * @param {EventEmitter} o * Optional
 * @return {mixed}
 */

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

/**
 * Triggers the binding of an event handler to all sockets for the given event name
 *
 * @param {string} name
 * @return SocketMessages
 */

SocketMessages.prototype.action = function (name) {
  if (typeof name === 'string' && this.actions().indexOf(name) < 0) {
    this.actions().push(name)
    this.emit('action', name);
  }
  return this;
};

/**
 * initializes the actions we have set so fare
 *
 * @return Array
 */

SocketMessages.prototype.actions = function () {
  if (!this._actions) {
    this._actions = [];
  }
  return this._actions;
};

module.exports = SocketMessages;

