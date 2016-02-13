# app.coffee
WebSocketServer = require('ws').Server
http = require('http')
express = require('express')
app = express();

app.use(express.static(__dirname + '/'));
server = http.createServer(app);
wss = new WebSocketServer({server:server});

class Room
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

    constructor: (location) ->
        @location = location
        @ws_list = []
        @id = Room.count
        Room.count++

    broadcast: (data) ->
        message = JSON.stringify data
        @ws_list.forEach (con, i) ->
            con.send(message);

wss.on 'connection', (ws) ->
    ws.on 'close', ->
        return if ws.room_id
        room = Room.find ws.room_id
        room.ws_list = room.ws_list.filter (x) -> x != ws

    ws.on 'message', (message) ->
        data = JSON.parse(message)
        console.log data
        console.log ws.hogehoge

        switch data.event
            when "location"
                location = data.location
                room = Room.findByLocation(location)
                if room = null
                    room = new Room(null)
                    Room.save room
                room.ws_list.push ws
                ws.room_id = room.id
            else
                if room = Room.all[0]
                    room.broadcast(ws.hogehoge)

server.listen(3000);

