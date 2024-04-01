const Sonoran = require("@sonoransoftware/sonoran.js");

let instance;
exports('initializeCAD', (CommID, APIKey, serverId, apiUrl, debug_mode) => {
    apiUrl = apiUrl.replace(/\/$/, '');
    instance = new Sonoran.Instance({
        communityId: CommID,
        apiKey: APIKey,
        serverId: serverId,
        product: Sonoran.productEnums.CMS,
        cmsApiUrl: apiUrl,
        debug: debug_mode
    });

    instance.on("CAD_SETUP_SUCCESSFUL", () => {
        console.log('ready to initialize')
    })

    instance.on("CAD_SETUP_UNSUCCESSFUL", (err) => {
        console.log(
            `Sonoran CAD Setup Unsuccessfully! Error provided: ${err}`
        );
    });

    exports('checkCMSWhitelist', (apiId, cb) => {
        instance.cms.verifyWhitelist(apiId).then((whitelist) => { cb(whitelist) })
    })

    exports('getFullWhitelist', (cb) => {
        instance.cms.getFullWhitelist().then((fullWhitelist) => { cb(fullWhitelist) })
    })
})