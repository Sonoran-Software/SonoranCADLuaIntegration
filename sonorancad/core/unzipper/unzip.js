var unzipper = require("unzipper");
var fs = require("fs");

exports('UnzipFile', (file, dest) => {
    fs.createReadStream(file).pipe(unzipper.Extract({ path: dest}));
});

function deleteDirR(dir) {
	fs.rmdir(dir, {recursive:true}, (err) => {
        if (err) {
            console.log(err)
            return false, err;
        }
    });
    return true;
}

exports('UnzipFolder', (file, name, dest) => {
    let firstDir = null;
	let hasStreamFolder = false;
	fs.createReadStream(file).pipe(unzipper.Parse())
	.on('entry', function(entry) {
		var fileName = entry.path;
		const type = entry.type;
		if (type == "Directory") {
			if (fileName.includes("stream") && !hasStreamFolder) {
				hasStreamFolder = true;
				deleteDirR(`${GetResourcePath(GetCurrentResourceName())}/stream/${name}/`);
			}
			if (firstDir == null) {
				firstDir = fileName;
			}
			else {
				fileName = fileName.replace(firstDir, "");
				if (!fs.existsSync(dest + fileName)) {
					fs.mkdirSync(dest + fileName);
				}
			}
		}
		if (type == "File") {
			fileName = fileName.replace(firstDir, "");
			let finalPath = dest + fileName;
			if (fileName.includes("stream")) {
                finalPath = fileName.replace(`${name}/stream/${name}`,`${GetResourcePath(GetCurrentResourceName())}/stream/${name}/`);
				if (!fs.existsSync(path.dirname(finalPath))) {
					fs.mkdirSync(path.dirname(finalPath));
				}
            }
			entry.pipe(fs.createWriteStream(finalPath));
		} else {
			entry.autodrain();
		}
	})
});

exports('CreateFolderIfNotExisting', (path) => {
    if (!fs.existsSync(path)) {
        fs.mkdirSync(path);
    }
});

exports('DeleteDirectoryRecursively', (dir) => {
    fs.rmdir(dir, {recursive:true}, (err) => {
        if (err) {
            console.log(err)
            return false, err;
        }
    });
    return true
});