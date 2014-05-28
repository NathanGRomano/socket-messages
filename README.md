# WIP

This library helps take events from client socket connections convert them into messages allows for them to be published to a message queue.

# Installation and Environment Setup

Install node.js (See download and install instructions here: http://nodejs.org/).

Install coffee-script

    > npm install coffee-script -g

Clone this repository

    > git clone git@github.com:NathanGRomano/message-exchange.git

cd into the directory and install the dependencies

    > cd message-exchange
    > npm install && npm shrinkwrap --dev

# Examples

Here is how we can setup socket-messages and listen to socket.io

First we get a server, socket.io instance, and a socket-messages object

```javascript

var server = require('http').createServer()
  , io = require('socket.io').listen(server) 
  , messages = require('socket-messages').listen(io)
  ;

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

Or if you the value is simply the identifier

```javascript

message.actor('user')

```

When we receive a message from the client can specify a method to extract *target*

```javascript

message.target(function (listOfArguments, cb) {

  if (!listOfArguments || !listofArguments.length)
    return cb(new Error('missing data'));

  var targetId = listOfArguments.shift()

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

Now we can setup logic to listen to messages.

```javascript

messages.action('say');

```

This will produce an object like this.

```javascript

{ action:'say', actor:'the socket id', created: 'the date', content: 'what was said', target: 'what the actor is targeting their action to' }

```

We can pass a method to manipulate the message before being published.

```javascript

messages.action('say', fuction (event, what) {
  event.content = what.toUpperCase();
});

```

# Running Tests

Tests are run using grunt.  You must first globally install the grunt-cli with npm.

    > sudo npm install -g grunt-cli

To run all the tests

    > grunt

## Unit Tests

To run the tests, just run grunt

    > grunt spec:unit

## End to End tests

To run the tests, just run grunt

    > grunt spec:e2e
