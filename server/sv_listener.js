/*
  SonoranCAD FiveM - A SonoranCAD integration for FiveM servers
   Copyright (C) 2020  Sonoran Software

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program in the file "LICENSE".  If not, see <http://www.gnu.org/licenses/>.
*/

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