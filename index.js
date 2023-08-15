const WebSocket = require("ws");
const WebServer = WebSocket.Server;
const url = require('url');

const wss = new WebServer({ port: process.env.PORT || 3000 });
let server = false

wss.on('connection',(ws, request)=>{
    let parsed = url.parse(request.url)
    ws.id = parsed.query

    if (parsed.query===null) {
        ws.id = 'unknown user'
    }

    console.log('connection found. (%s)', ws.id);

    if (server!==false) {
        ws.send(server)
    }

    ws.on('error', console.error);

    ws.on('close',()=>{
        console.log('connection closed. (%s)', ws.id);
    });

    ws.on('message',(message)=>{
        const messageString = message.toString().split('|');

        if (message.toString()==='ping') {
            ws.send('pong')
        } else {
            console.log("message sent. (%s from %s)", message, ws.id);
        }

        if (message.toString()==='SUPER SECRET MESSAGE') {
            server = false
        }

        if (messageString[0]===' SUPER SECRET MESSAGE ') {
            server = messageString[1]
            wss.clients.forEach(function each(client){
                if(client!==ws&&client.readyState===WebSocket.OPEN&&client.id!=='unknown user'){
                    client.send(messageString[1]);
                }
            });
        }
    });
});

console.log("started listening.");
