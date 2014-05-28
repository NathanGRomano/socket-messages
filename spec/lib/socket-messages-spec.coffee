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
    Given -> @instance = new @SocketMessages
    Given ->
      @io = new EventEmitter
      spyOn(@io,['on']).andCallThrough()
      spyOn(@io,['removeListener']).andCallThrough()

    describe '#attach', ->

      When -> @instance.attach @io
      Then -> expect(@io.on).toHaveBeenCalledWith 'connection', @instance.onConnection

    describe '#dettach', ->

      When -> @instance.dettach @io
      Then -> expect(@io.removeListener).toHaveBeenCalledWith 'connection', @instance.onConnection

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

