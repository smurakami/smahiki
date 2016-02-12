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

    ws.on 'message', (message) ->
        data = JSON.parse(message)
        console.log data

        switch data.event
            when "location"
                room = new Room(null)
                room.ws_list.push ws
                Room.all.push room
            else
                if room = Room.all[0]
                    room.broadcast(data)

server.listen(3000);
