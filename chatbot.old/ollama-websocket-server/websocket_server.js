const { Server, OPEN } = require('ws');

// Create a WebSocket server instance on port 8080
const wss = new Server({ port: 8080 });

// Event listener for connection opening
wss.on('connection', function connection(ws) {
  console.log('A new client connected.');

  // Create a WebSocket client to connect to the server on port 11434
  const client = new WebSocket('ws://localhost:11434');

  // Event listener for receiving messages from the server on port 11434
  client.on('message', function incoming(message) {
    console.log('Received message from server:', message);

    // Forward the message received from the server to the WebSocket clients connected to port 8080
    wss.clients.forEach(function each(client) {
      if (client.readyState === OPEN) {
        client.send(message);
      }
    });
  });

  // Event listener for receiving messages from WebSocket clients connected to port 8080
  ws.on('message', function incoming(message) {
    console.log('Received message from client:', message);
    // ws.send('Message received by the WebSocket server');
  });
});

console.log('WebSocket server running on port 8080');
