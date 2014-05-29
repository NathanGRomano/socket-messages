This library helps take events from client socket connections convert them into messages allows for them to be published to a message queue.
It was built to work with socket.io but does not require it.

# Installation and Environment Setup

Install node.js (See download and install instructions here: http://nodejs.org/).

Install coffee-script

    > npm install coffee-script -g

Clone this repository

    > git clone git@github.com:NathanGRomano/socket-messages.git

cd into the directory and install the dependencies

    > cd message-exchange
    > npm install && npm shrinkwrap --dev

# Examples

Here is how we can setup socket-messages and have it listen to socket.io.

```javascript

var io = require('socket.io')();
io.listen(3000);

var messages = require('socket-messages').listen(io);

```

A message encapsulates an actor performing an action on a target with some content.

Each socket needs an actor.  You must specifiy an method to grab the *actor*.  If you do
not specify the actor the assigned socket id will be used.

```javascript

messages.actor(function (socket, cb) {
  if (socket.handshake && 
      socket.handshake.session &&
      socket.handshake.session.name) {
     cb(null, socket.handshake.session.name);
  }
  else {
     cb(new Error('Invalid Session'));
  }
});

```
Messages have a *target* we can specify a method to extract the target from the *params* received.

```javascript

message.target(function (socket, params, cb) {

  if (!params || !params.length)
    return cb(new Error('missing data'));

  var targetId = params.shift()

  cb(null, targetId);

});

```

If we do not specify a target extractor.  The default target will be the actor.

The *messages* object will construct a *message* and publish it to an exchange.

An exchange is just an event emitter.

```javascript

var exchange = new require('events').EventEmitter();

```

Attach the messages to the exchange.

```javascript

messages.exchange(exchange);

```

We can listen to actions by calling *action* and passing in the *name* of the action.

```javascript

messages.action('say');

```

When the *socket* receives an *event*, *messages* will produce an object like this.

```javascript

{
  "created":"2014-05-29T14:34:36.942Z",
  "action":"say",
  "actor":"vL3fesBeM5ixbqhNAAAA",
  "target":"you",
  "content":["hello, world!"]
 }

```

# Running Tests

Tests are run using grunt.  You must first globally install the grunt-cli with npm.

    > sudo npm install -g grunt-cli

## Unit Tests

To run the tests, just run grunt

    > grunt spec:unit

## TODO

We can pass a method to manipulate the message before being published.

```javascript

messages.action('say', fuction (event, what, cb) {
  event.content = what.toUpperCase();
  cb();
});

```
