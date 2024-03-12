const path = require("path");
exports("SaveBase64ToFile", function (base64String, filename) {
	let base64Image = base64String.split(";base64,").pop();
	fs.writeFile(filename, base64Image, { encoding: "base64" }, function (err) {
		return true;
	});
});

exports("createScreenshotDirectory", function (apiID) {
	let dir = `${GetResourcePath(GetCurrentResourceName())}/screenshots/${apiID}`;
	if (!fs.existsSync(dir)) {
		fs.mkdirSync(dir);
	}
	return dir;
});

exports("createScreenshotFilename", function(directory) {
    // Get all jpg files with their full paths
    let files = fs.readdirSync(directory)
        .filter(file => file.endsWith(".jpg"))
        .map(file => ({
            name: file,
            time: fs.statSync(path.join(directory, file)).mtime.getTime()
        }))
        .sort((a, b) => a.time - b.time); // Sort files by modification time, oldest first

    let nextFileNumber;
    if (files.length >= 10) {
        // If we have 10 or more files, increment the highest number by 1 and delete the oldest file if more than 10 files exist
        const highestNumber = Math.max(...files.map(file => parseInt(file.name.replace('.jpg', ''), 10)));
        nextFileNumber = highestNumber + 1;
        if (files.length > 10) {
            // Delete the oldest file
            const oldestFile = files[0].name;
            fs.unlinkSync(path.join(directory, oldestFile));
        }
    } else {
        // If less than 10 files, find the first number not used
        let existingNumbers = files.map(file => parseInt(file.name, 10));
        nextFileNumber = 1;
        for (let i = 1; i <= 10; i++) {
            if (!existingNumbers.includes(i)) {
                nextFileNumber = i;
                break;
            }
        }
    }
    return `${nextFileNumber}.jpg`;
});
