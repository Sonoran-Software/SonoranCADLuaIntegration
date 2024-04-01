const { format } = require("path");

function byteCount(s) {
    return encodeURI(s).split(/%..|./).length - 1;
}

exports('HandleHttpRequest', (dest, callback, method, data, headers) => {
    emit("SonoranCAD::core:writeLog", "debug", "[http] to: " + dest + " - data: " + dest, JSON.stringify(data));
    const urlObj = url.parse(dest)
    const options = {
        hostname: urlObj.hostname,
        path: urlObj.pathname,
        method: method,
        headers: headers
    }
    if (method == "POST") {
        options.headers['Content-Type'] = 'application/json'
    }
    else if (method != "GET") {
        console.error("Invalid request. Only GET/POST supported. Method: " + method);
        callback(500, "", {});
        return;
    }
    options.headers['X-SonoranCAD-Version'] = GetResourceMetadata(GetCurrentResourceName(), "version", 0)
    //console.debug("send to: " + dest);
    const req = https.request(options, (res) => {
        let output = "";
        res.on('data', (d) => {
            output += d.toString()
        }),
        res.on('end', () => {
            callback(res.statusCode, output, res.headers);
        })
      })
        
    req.on('error', (error) => {
        let ignore_ids = ["EAI_AGAIN", "ETIMEOUT", "ENOTFOUND"]
        if (!ignore_ids.includes(error.code))
            console.debug("HTTP error caught: " + JSON.stringify(error));
        callback(error.errono, {}, {});
    })
    if (method == "POST") {
        req.write(data);
    }
    req.end();
});