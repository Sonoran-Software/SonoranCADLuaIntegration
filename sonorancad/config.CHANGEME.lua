-- rename this file to config.lua before using!
Config.communityID = ""
Config.apiKey = ""
--Config.apiUrl = 'https://cadapi.dev.sonoransoftware.com/'
Config.apiUrl = "https://api.sonorancad.com/"
Config.postTime = 5000 --Recommended to stay above 5000ms3
Config.serverId = "1" -- Default is 1
Config.serverType = "standalone" -- Either specify "standalone" or "esx", "standalone" will use Player Name as the Caller ID, and "esx" will use "esx-identity" to use your character's name.
Config.primaryIdentifier = "steam" -- Used for location data. What ID will players specify?
Config.apiSendEnabled = true -- Set to false to disable sending over the API and you use your own 911 handler

Config.debugMode = false -- When set to true, print every web request to console. Very spammy, only set if asked to by support!