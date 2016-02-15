# app.coffee
class Room
  constructor: (ws, location) ->
    @id = Room.count
    Room.count++

    @location = location
    @ws_list = []
    @addWS ws
    @started = false
    @finished = false

    # チームに関する値
    @scroll_value =
      a: 0
      b: 0
    @start()

  addWS: (ws) ->
    @ws_list.push ws
    ws.room = @

  removeWS: (ws) ->
    ws.room = null
    @ws_list = @ws_list.filter (x) -> x != ws

  destroy: ->
    @finished = true
    Room.all = Room.all.filter (x) => x != @

  start: ->
    interval = 0.5
    _loop = =>
      return if @finished
      if @started
        @broadcast
          event: "scroll"
          value: @scroll_value
      setTimeout _loop, 1000 * interval
    _loop()

  broadcast: (data) ->
    message = JSON.stringify data
    @ws_list.forEach (con, i) ->
      con.send(message);

  #: ---- class methods
  @count = 0
  @all = []
  @find = (id) ->
    for r in Room.all
      if r.id == id
        return r
    return null
  @save = (room) ->
    Room.all.push room

  locToPos = (loc) ->
    a = loc.longitude / 180 * Math.PI
    b = loc.latitude / 180 * Math.PI
    radius = 6378137 # 地球半径[m]
    sin = Math.sin
    cos = Math.cos
    x = cos(b) * cos(a) * radius
    y = cos(b) * sin(a) * radius
    z = sin(b) * radius
    return {x: x, y: y, z: z}

  dist = (a, b) ->
    dx = a.x - b.x
    dy = a.y - b.y
    dz = a.z - b.z
    return Math.sqrt(dx * dx, dy * dy, dz * dz)

  @findByLocation = (loc) ->
    loc_th = 5000 # [m] これよりも遠いお部屋には入れない
    pos = locToPos(loc)
    sorted = Room.all.concat().sort (a, b) ->
      a_pos = locToPos(a.location)
      b_pos = locToPos(a.location)
      return dist(a_pos, pos) - dist(b_pos, pos)
    head = sorted[0]
    return null unless head?
    d = dist(locToPos(head.location), pos)
    return null if d > loc_th # 遠くにある部屋には入れない
    return head


class Main
  constructor: ->
    @setupWSS()
  setupWSS: ->
    WebSocketServer = require('ws').Server
    http = require('http')
    express = require('express')
    app = express();
    app.use(express.static(__dirname + '/'));
    server = http.createServer(app);

    self = @
    @wss = new WebSocketServer({server:server});
    @wss.on 'connection', (ws) ->
      ws.on 'close', ->
        self.closeConnection(ws)
      ws.on 'message', (message) ->
        self.onMessage ws, message
    server.listen(3000);

  closeConnection: (ws) ->
    console.log 'close'
    return unless ws.room?
    room = ws.room
    room.removeWS ws
    console.log "length : #{room.ws_list.length}"
    if room.ws_list.length == 0
      room.destroy()

  onMessage: (ws, message) ->
    data = JSON.parse(message)
    console.log data
    switch data.event
      when "location"
        @assignRoom ws, data
      when "scroll"
        @scroll ws, data

  send: (ws, object) -> ws.send JSON.stringify(object)

  assignRoom: (ws, data) ->
    location = data.location
    room = Room.findByLocation(location)
    if room?
      room.addWS ws
    else
      room = new Room(ws, location)
      Room.save room
    @send ws,
      event: "location"
      room_id: ws.room.id

  scroll: (ws, data) ->
    room = ws.room
    value = data.value
    team = data.team
    switch team
      when "a"
        room.scroll_value.a += value
      when "b"
        room.scroll_value.b += value


process.on 'uncaughtException', (err) ->
    console.log err

main = new Main()
