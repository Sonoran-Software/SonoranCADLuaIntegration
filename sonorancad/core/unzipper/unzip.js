var unzipper = require("unzipper");
var fs = require("fs");

exports('UnzipFile', (file, dest) => {
    fs.createReadStream(file).pipe(unzipper.Extract({ path: dest}));
});