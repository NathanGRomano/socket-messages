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

        Given ->
          @socket = new EventEmitter
          @socket.handshake =
            session:
              name: 'I'
          @socket.id = 'Some'

        context 'with the default method', ->

          Given -> @cb = jasmine.createSpy 'cb'
          When -> @instance.actor @socket, @cb
          Then -> expect(@cb).toHaveBeenCalledWith null, 'Some'

        context 'with a custom method', ->

          Given -> @cb = jasmine.createSpy 'cb'
          Given -> @instance.actor @fn
          When -> @instance.actor @socket, @cb
          Then -> expect(@cb).toHaveBeenCalledWith null, 'I'
