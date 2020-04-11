local communityID = ""
local apiKey = ""
local apiURL = 'https://sonorancad.com/api/emergency'
local postTime = 5000 --Recommended to stay above 5000ms3
local serverId = "1" -- Default is 1
local serverType = "standalone" -- Either specify "standalone" or "esx", "standalone" will use Player Name as the Caller ID, and "esx" will use "esx-identity" to use your character's name.
local primaryIdentifier = "steam" -- Used for location data. What ID will players specify?
local apiSendEnabled = true -- Set to false to disable sending over the API and you use your own 911 handler