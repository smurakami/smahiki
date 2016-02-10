class Socket
  constructor: ->
    console.log 'hello'
    @initWebSocket()

  initWebSocket: ->
    self = @
    host = window.document.location.host.replace(/:.*/, '')
    @ws = new WebSocket('ws://' + host + ':3000')
    @ws.onmessage = (event) ->
      if self.received != null
        self.onmessage JSON.parse(JSON.parse(event.data))

  send: (data) ->
    @ws.send(JSON.stringify(data))

  receive: (fn) ->
    @onmessage = fn


global = this
$ ->
  global.socket = new Socket()

  socket.receive (data) ->
    console.log data

  setInterval ->
    socket.send {hoge: 2}
  , 1000
