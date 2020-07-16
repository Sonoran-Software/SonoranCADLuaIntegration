
//url, cb, method, data, headers
exports('HandleHttpRequest', (dest, callback, method, data, headers) => {
    const urlObj = url.parse(dest)
    const options = {
        hostname: urlObj.hostname,
        path: urlObj.pathname,
        method: method,
        headers: headers
    }
    if (method == "POST") {
        options.headers['Content-Type'] = 'application/json',
        options.headers['Content-Length'] = data.length
    }
    else if (method != "GET") {
        console.error("Invalid request. Only GET/POST supported. Method: " + method);
        callback(500, "", {});
        return;
    }

    const req = https.request(options, (res) => {
        res.on('data', (d) => {
            callback(res.statusCode, d.toString(), res.headers);
        })
      })
        
    req.on('error', (error) => {
        console.error(error);
    })
    if (method == "POST") {
        req.write(data);
    }
    req.end();
});