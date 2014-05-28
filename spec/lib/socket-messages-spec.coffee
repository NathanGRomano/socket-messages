EventEmitter = require('events').EventEmitter

describe 'SocketMessages', ->

  Given -> @SocketMessages = requireSubject 'lib/socket-messages', {}
  
  describe '#listen', ->

    Given ->
      @io = new EventEmitter
      spyOn(@io,['on']).andCallThrough()
    When -> @res = @SocketMessages.listen @io
    Then -> expect(@res instanceof @SocketMessages).toBe true


