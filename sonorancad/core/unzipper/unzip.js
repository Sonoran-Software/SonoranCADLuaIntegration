var unzipper = require("unzipper");
var fs = require("fs");

exports('UnzipFile', (file, dest) => {
    fs.createReadStream(file).pipe(unzipper.Extract({ path: dest}));
});

exports('UnzipFolder', (file, name, dest) => {
    fs.createReadStream(file).pipe(unzipper.Parse())
    .on('entry', function(entry) {
        var fileName = entry.path;
        const type = entry.type;
        const fprefix = "sonoran_" + name + "-latest/" + name + "/"
        const file = fileName.replace(/^.*[/]/, '');
        if (fileName.indexOf(fprefix) > -1 && type == "File") {
            console.log("extract " + file)
            if (fs.existsSync(dest + "/" + name)) {
                entry.pipe(fs.createWriteStream(dest + "/" + name + "/" + file));
            } else {
                entry.pipe(fs.createWriteStream(dest + "/" + file));
            }
            
        } else {
            entry.autodrain();
        }
    })
});