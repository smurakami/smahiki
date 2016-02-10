class Socket
  constructor: ->
    console.log 'hello'
    @initWebSocket()

  initWebSocket: ->
    self = @
    host = window.document.location.host.replace(/:.*/, '')
    @ws = new WebSocket('ws://' + host + ':3000')
    @ws.onmessage = (event) ->
      self.received JSON.parse(JSON.parse(event.data))

  send: (data) ->
    @ws.send(JSON.stringify(data))

  received: (data) ->

global = this
$ ->
  global.socket = new Socket()
