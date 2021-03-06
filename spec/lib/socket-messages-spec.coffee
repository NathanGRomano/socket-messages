EventEmitter = require('events').EventEmitter

describe 'SocketMessages', ->

  Given -> @SocketMessages = requireSubject 'lib/socket-messages', {}

  describe '#make', ->
    When -> @res = @SocketMessages.make()
    Then -> expect(@res instanceof @SocketMessages).toBe true
  
  describe '#listen', ->

    Given ->
      @io = new EventEmitter
      spyOn(@io,['on']).andCallThrough()
    Given -> spyOn(@SocketMessages,['make']).andCallThrough()
    When -> @res = @SocketMessages.listen @io
    Then -> expect(@SocketMessages.make).toHaveBeenCalled()
    And -> expect(@io.on).toHaveBeenCalledWith 'connection', @res.onConnection

  context 'an instance', ->

    Given ->
      @socket = new EventEmitter
      @socket.handshake =
        session:
          name: 'I'
      @socket.id = 'Me'
      spyOn(@socket,['emit']).andCallThrough()
      spyOn(@socket,['on']).andCallThrough()
    Given ->
      @instance = new @SocketMessages
      spyOn(@instance,['emit']).andCallThrough()
    Given ->
      @io = new EventEmitter
      @io.sockets = fns: []
      @io.use = (fn) -> @sockets.fns.push fn
      spyOn(@io,['on']).andCallThrough()
      spyOn(@io,['removeListener']).andCallThrough()
      spyOn(@io,['use']).andCallThrough()

    describe '#attach', ->

      When -> @instance.attach @io
      Then -> expect(@io.on).toHaveBeenCalledWith 'connection', @instance.onConnection
      And -> expect(@io.use).toHaveBeenCalledWith @instance.middleware

    describe '#dettach', ->

      Given -> spyOn(@io.sockets.fns,['splice']).andCallThrough()
      When -> @instance.dettach @io
      Then -> expect(@io.removeListener).toHaveBeenCalledWith 'connection', @instance.onConnection
      And -> expect(@io.sockets.fns,['splice']).toHaveBeenCaleldWith 0, 1

    describe '#actor', ->

      Given -> @fn = (socket, cb) ->
        cb null, socket.handshake.session.name

      context 'with a function', ->

        When -> @res = @instance.actor(@fn).actor()
        Then -> expect(@res).toBe @fn

      context 'with an object, and callback', ->

        context 'with the default method', ->

          Given -> @cb = jasmine.createSpy 'cb'
          When -> @instance.actor @socket, @cb
          Then -> expect(@cb).toHaveBeenCalledWith null, 'Me'

        context 'with a custom method', ->

          Given -> @cb = jasmine.createSpy 'cb'
          Given -> @instance.actor @fn
          When -> @instance.actor @socket, @cb
          Then -> expect(@cb).toHaveBeenCalledWith null, 'I'

    describe '#target', ->

      Given -> @fn = (socket, params, cb) ->
        cb null, params.shift()

      context 'with a function', ->

        When -> @res = @instance.target(@fn).target()
        Then -> expect(@res).toBe @fn

      context 'with param list, and callback', ->

        Given -> @params = ['You']

        context 'with the default method', ->

          Given -> @cb = jasmine.createSpy 'cb'
          When -> @instance.target @socket, @params, @cb
          Then -> expect(@cb).toHaveBeenCalledWith null, 'Me'

        context 'with a custom method', ->

          Given -> @cb = jasmine.createSpy 'cb'
          Given -> @instance.target @fn
          When -> @instance.target @socket, @params, @cb
          Then -> expect(@cb).toHaveBeenCalledWith null, 'You'

    describe '#exchange', ->

      Given -> @exchange = new EventEmitter

      context 'with no arguments', ->

        When -> @res = @instance.exchange()
        Then -> expect(@res instanceof EventEmitter).toBe true

      context 'with an object', ->

        When -> @res = @instance.exchange(@exchange).exchange()
        Then -> expect(@res).toBe @exchange

    describe '#actions', ->

      When -> @res = @instance.actions()
      Then -> expect(@res).toEqual []

    describe '#action', ->

      Given -> @name = 'say'
      When -> @instance.action @name
      Then -> expect(@instance.emit).toHaveBeenCalledWith 'action', @name
      And -> expect(@instance.actions()).toEqual [@name]

    describe '#onConnection', ->

      Given -> @other = 'other'
      Given -> @name = 'say'
      When ->
        @instance.action @other
        @instance.onConnection @socket
        @instance.action @name
      Then -> expect(@socket.on).toHaveBeenCalledWith @name, jasmine.any(Function)
      And -> expect(@socket.listeners(@other).length).toBe 1
      And -> expect(@socket.listeners(@name).length).toBe 1

      describe 'socket emits action', ->
        Given -> @a = 'you'
        Given -> @b = 'what'
        Given -> spyOn(@instance,['onMessage'])
        When -> @socket.emit @name, @a, @b
        Then -> expect(@instance.onMessage).toHaveBeenCalledWith @socket, [@name, @a, @b]

      describe 'when the socket is disconnected', ->
        Given -> spyOn(@socket,['removeAllListeners']).andCallThrough()
        When -> @socket.emit 'disconnect'
        Then -> expect(@instance.listeners('action').length).toBe 0
        And -> expect(@socket.listeners(@other).length).toBe 0
        And -> expect(@socket.listeners(@name).length).toBe 0
        And -> expect(@socket.removeAllListeners).toHaveBeenCalled()

    describe '#onMessage', ->
      Given -> @actor = 'I'
      Given -> @action = 'say'
      Given -> @target = 'You'
      Given -> @content = 'what'
      Given -> @params = [@action, @target, @content]
      Given -> spyOn(@instance,['actor']).andCallThrough()
      Given -> spyOn(@instance,['target']).andCallThrough()
      Given -> spyOn(@instance,['exchange']).andCallThrough()
      Given -> spyOn(@instance.exchange(),['emit']).andCallThrough()
      Given -> @instance.actor (socket, cb) -> cb null, socket.handshake.session.name
      Given -> @instance.target (socket, args, cb) -> cb null, args.shift()
      When -> @instance.onMessage @socket, @params
      Then -> expect(@instance.actor).toHaveBeenCalledWith @socket, jasmine.any(Function)
      And -> expect(@instance.target).toHaveBeenCalledWith @socket, [@content], jasmine.any(Function)
      And -> expect(@instance.exchange).toHaveBeenCalled()
      And -> expect(@instance.exchange().emit).toHaveBeenCalled()
      And -> expect(@instance.exchange().emit.mostRecentCall.args[0]).toBe 'message'
      And -> expect(@instance.exchange().emit.mostRecentCall.args[1].created instanceof Date).toBe true
      And -> expect(@instance.exchange().emit.mostRecentCall.args[1].actor).toBe @actor
      And -> expect(@instance.exchange().emit.mostRecentCall.args[1].target).toBe @target
      And -> expect(@instance.exchange().emit.mostRecentCall.args[1].action).toBe @action
      And -> expect(@instance.exchange().emit.mostRecentCall.args[1].content).toEqual [@content]
      And -> expect(@instance.exchange().emit.mostRecentCall.args[2]).toEqual @socket

    describe '#autoPropagate', ->

      Then -> expect(@instance.autoPropagate()).toBe false

    describe '#autoPropagate (v:Boolean=false)', ->

      When -> @instance.autoPropagate false
      Then -> expect(@instance.autoPropagate()).toBe false

    describe '#autoPropagate (v:Boolean=true)', ->

      When -> @instance.autoPropagate true
      Then -> expect(@instance.autoPropagate()).toBe true

    describe '#middleware (socket:Object, next:Function)', ->

      Given -> @socket = new EventEmitter
      Given -> @next = jasmine.createSpy 'next'
      When -> @instance.middleware @socket, @next
      Then -> expect(@socket.onevent).toBe @instance.onSocketEvent
      And -> expect(@next).toHaveBeenCalled()

    describe.only '#onSocketEvent (packet:Object)', ->

      context 'autoPropagation(v:Boolean=false)', ->

        Given -> spyOn(EventEmitter.prototype.emit,['apply']).andCallThrough()
        Given -> @socket = new EventEmitter
        Given -> @cb = jasmine.createSpy 'cb'
        Given -> @socket.addListener 'test', @cb
        Given -> spyOn(@socket,['emit']).andCallThrough()
        Given -> @fn = ->
        Given -> @socket.ack = (a) => @fn
        Given -> spyOn(@socket,['ack']).andCallThrough()
        Given -> @socket.onSocketEvent = @instance.onSocketEvent
        Given -> @packet = id: 1, data: ['test']
        Given -> @instance.autoPropagate false
        When -> @socket.onSocketEvent @packet
        Then -> expect(@socket.ack).toHaveBeenCalledWith @packet.id
        And -> expect(EventEmitter.prototype.emit.apply).toHaveBeenCalledWith @socket, ['test', @fn]
        And -> expect(@cb).toHaveBeenCalledWith @fn

      context 'autoPropagation(v:Boolean=true)', ->

        Given -> spyOn(@instance,['onMessage'])
        Given -> @socket = new EventEmitter
        Given -> spyOn(@socket,['emit']).andCallThrough()
        Given -> @fn = ->
        Given -> @socket.ack = (a) => @fn
        Given -> spyOn(@socket,['ack']).andCallThrough()
        Given -> @socket.onSocketEvent = @instance.onSocketEvent
        Given -> @packet = id: 1, data: ['test']
        Given -> @instance.autoPropagate true
        When -> @socket.onSocketEvent @packet
        Then -> expect(@socket.ack).toHaveBeenCalledWith @packet.id
        And -> expect(@instance.onMessage).toHaveBeenCalledWith @socket, ['test', @fn]
