# app.coffee
WebSocketServer = require('ws').Server
http = require('http')
express = require('express')
app = express();

app.use(express.static(__dirname + '/'));
server = http.createServer(app);
wss = new WebSocketServer({server:server});

connections = [];

wss.on 'connection', (ws) ->
    connections.push(ws);
    ws.on 'close', ->
        connections = connections.filter  (conn, i) ->
            return if conn == ws then false else true

    ws.on 'message', (message) ->
        console.log('message:', message);
        broadcast(JSON.stringify(message))

broadcast = (message) ->
    connections.forEach (con, i) ->
        con.send(message);

server.listen(3000);
