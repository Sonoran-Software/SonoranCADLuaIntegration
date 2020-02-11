let config = require("./config.json");
const listenPort = GetConvarInt('SonoranListenPort', 3232);

var http = require('http');


http.createServer(function (req, res) {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  let response = '';

  if (req.method == 'POST') {
    req.on('data', function(chunk) {
	    const body = JSON.parse(chunk.toString());
      if (body.key === config.apiKey) {
        response = 'Success!';
        emit('recieveListenerData', body);
      } else {
        response = 'Invalid API Key!';
      }
    });
  } else {
    response = 'Invalid request type, not a POST!';
  }

  setTimeout(function(){
	  res.write(response);
	  res.end();
  }, 0);
}).listen(listenPort);