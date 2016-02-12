class Socket
  constructor: ->
    @initWebSocket()

  initWebSocket: ->
    self = @
    host = window.document.location.host.replace(/:.*/, '')
    @ws = new WebSocket('ws://' + host + ':3000')
    @ws.onmessage = (event) ->
      if self.received != null
        self.onmessage JSON.parse(event.data)
    @ws.onopen = () ->
      if self.onopen
        self.onopen()
    @ws.onerror = (error) ->
      console.log('WebSocket Error ' + error)
    @ws.onclose = (error) ->
      console.log('WebSocket Error ' + error)
  send: (data) ->
    @ws.send(JSON.stringify(data))

  receive: (fn) ->
    @onmessage = fn

  open: (fn) ->
    @onopen = fn

global = this
$ ->
  global.socket = new Socket()

  socket.receive (data) ->
    console.log data.data.hoge

  socket.open ->
    socket.send
      event: "location"

  setInterval ->
    console.log 'send'
    socket.send
      event: "hoge"
      data: {hoge: 2}
  , 1000
