EventEmitter = require('events').EventEmitter

SocketMessages = requireSubject '.', { }

describe 'socket messages',

  Given ->
    @io = new EventEmitter

  Given ->
    @socketMessages = SocketMessages.listen @io
    @socketMessages.exchange @exchange
    @socketMessages.actor (socket, cb) ->
      cb null, socket.handshake.session.name
    @socketMessages.target (params, cb) ->
      cb null, params.shift()
    @socketMessages.action 'say', (event, content) ->
      event.content = content.toUpperCase() + '!!!'

  Given ->
    @socket = new EventEmitter
    @socket.handshake =
      session:
        name: 'I'

  describe 'binding listener to the socket', ->

    Given -> spyOn(@socketMessages,['bind']).andCallThrough()
    When -> @io.emit 'connection', @socket
    Then -> expect(@socketMessages.bind).toHaveBeenCalledWith @socket

    describe 'producing a mesage from an event received on a socket', ->
      Given ->
        @exchange = new EventEmitter
        spyOn(@exchange, ['emit']).andCallThrough()
        @socketMessages.exchange @exchange
      Given -> @targetId = 'you'
      Given -> @content = 'what'
      Given -> @params = [@targetId, @content]
      When -> @socket.emit 'say', 'you', 'what'
      Then -> expect(@exchange.emit).toHaveBeenCalled()
      And -> expect(@exchange.emit.mostRecentCall.args[0]).toBe 'message'
      And -> expect(@exchange.emit.mostRecentCall.args[1].actor).toBe 'I'
      And -> expect(@exchange.emit.mostRecentCall.args[1].action).toBe 'say'
      And -> expect(@exchange.emit.mostRecentCall.args[1].content).toBe 'WHAT!!!'
      And -> expect(@exchange.emit.mostRecentCall.args[1].target).toBe 'You'
      And -> expect(@exchange.emit.mostRecentCall.args[1].created instanceof Date).toBe true

