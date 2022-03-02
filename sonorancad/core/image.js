exports('SaveBase64ToFile', function(base64String, filename) {
    let base64Image = base64String.split(';base64,').pop();
    fs.writeFile(filename, base64Image, { encoding: 'base64'}, function(err) {
        return true;
    })
})