-- rename this file to config.lua before using!
communityID = ""
apiKey = ""
apiURL = 'https://sonorancad.com/api/emergency'
postTime = 5000 --Recommended to stay above 5000ms3
serverId = "1" -- Default is 1
serverType = "standalone" -- Either specify "standalone" or "esx", "standalone" will use Player Name as the Caller ID, and "esx" will use "esx-identity" to use your character's name.
primaryIdentifier = "steam" -- Used for location data. What ID will players specify?
apiSendEnabled = true -- Set to false to disable sending over the API and you use your own 911 handler

-- POSTAL CONFIG --
prefixPostal = false -- when enabled, location of caller will be prefixed with the postal code from a postal script

-- IF ABOVE IS SET TO TRUE, MODIFY postal_client.lua TO SEND POSTAL DATA TO THE SERVER!