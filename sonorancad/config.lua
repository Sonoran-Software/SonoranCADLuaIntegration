Config = {
    Core = {
        -- Credentials for the CAD system
        CommunityID = "",
        ApiKey = "",
        -- Mode: "production" or "development"
        Mode = "production",
        -- Debug mode, will print additional logs to the console
        DebugMode = false,
        -- The Server ID in the CAD settings, override with convar `setr sonorancad_server_id`
        ServerID = "1",
        -- Primary identifier for players, default is "steam". Valid values: "steam", "license", "discord"
        PrimaryIdentifier = "steam",
        UpdateBranch = "master",
        StatusLabels = ["UNAVAILABLE", "BUSY", "AVAILABLE", "ENROUTE", "ON_SCENE"],
        AllowAutoUpdate = true,
        AutoUpdateUrl = "",
        AllowUpdateWithPlayers = false,
        -- URL to send push events to like they were from the CAD system, leave blank to disable
        PushEventForwardingUrl = "",
        -- When true, the CAD will not attempt to fix the server IP address in the CAD settings. This is useful for servers that are behind a proxy.
        DisableAutoIp = false,
    },

    -- Bodycam configuration
    BodyCam = {
        Enabled = true,
        BeepFrequency = 300000,
        ScreenshotFrequency = 2000,
        PlayBeeps = true,
        OverlayEnabled = true,
        OverlayLocation = "top-right",
        CommandToggle = "bodycam",
        CommandChangeFrequency = "bodycamfreq",
    },

    -- Locations and postals
    LocationSystem = {
        -- enable location tracking, also enables postal tracking if resource is started
        Enabled = true,
        -- how frequently to send locations to the server
        CheckTime = 1000,
        -- prefix postal code on locations sent, requires postal plugin
        PrefixPostal = true,
        -- when enabled, only online units will send location updates. Only recommended for large servers.
        SendOnlyUnitLocation = false,
        -- how often to send postal to client
        PostalSendTimer = 950, 
        -- if using nearestpostal, specify the name of the resource here if you changed it
        NearestPostalResourceName = "nearest-postal", 
        -- optionally use an event fired by another resource, set mode to "event" and add the name of the event below
        Mode = "resource",
        NearestPostalEvent = "",
        -- if not using nearest-postal, place a json file containing the postals in the plugin's folder and specify a name below
        CustomPostalCodesFile = ""
    },

    -- Previously callcommands and dispatchnotify
    CallSystem = {
        -- enable call command
        EnableCallCommand = true,
        -- types of call commands
        CallTypes = {
            { command = "911", isEmergency = true, suggestionText = "Sends a emergency call to your SonoranCAD", descriptionPrefix = "" },
            { command = "311", isEmergency = false, suggestionText = "Sends a non-emergency call to your SonoranCAD", descriptionPrefix = "(311)" },
            { command = "511", isEmergency = false, suggestionText = "Sends a call for a towing service.", descriptionPrefix = "(511)" }
        },
        EnablePanic = true,
        -- adds an emergency call when panic button is pressed
        AddPanicCall = true,

        --[[
            Enable incoming 911 call notifications
        ]]
        EnableUnitNotify = true,
        --[[
            Specifies what emergency calls are displayed as. Some countries use different numbers (like 999)
        ]]
        EmergencyCallType = "911",
        --[[
            Specifies non-emergency call types. If unused, set to blank ("")
        ]]
        CivilCallType = "311",
        --[[
            Some communities use 511 for tow calls. Specify below, or set blank ("") to disable
        ]]
        DotCallType = "511",

        --[[
            Command to respond to calls with
        ]]
        RespondCommandName = "rcall",

        --[[
            Enable call responding (self-dispatching)

            If disabled, running commandName will return an error to the unit
        ]]
        EnableUnitResponse = true,

        --[[
            If a dispatcher is detected to be online, automatically disable the response command.
        ]]
        DispatchDisablesSelfResponse = false,

        --[[
            Enable "units are on the way" notifications
        ]]
        EnableCallerNotify = true,
        --[[
            notifyMethod: how should the caller be notified?
                none: disable notification
                chat: Sends a message in chat
                pnotify: Uses pNotify to show a notification
                custom: Use the custom event instead (see docs)
        ]]
        CallerNotifyMethod = "chat",
        --[[
            notifyMessage: Message template to use when sending to the player

            You can use the following replacements:
                {officer} - officer name
        ]]
        NotifyMessage = "Officer {officer} is responding to your call!",

        --[[
            Enable "incoming call" messages sent to your units.
        ]]
        EnableUnitNotify = true,

        --[[
            unitNotifyMethod: how should units be notified?
                none: disable notification
                chat: Sends a message in chat
                pnotify: Uses pNotify to show a notification
                custom: Use the custom event instead (see docs)
        ]]
        UnitNotifyMethod = "chat",
        --[[
            incomingCallMessage: how should officers be notified of a new 911 call?

            Parameters:
                {location} - location of call (street + postal)
                {description} - description as given by civilian
                {caller} - caller's name
                {callId} - ID of the call so LEO can respond with /r911 <id>
                {command} - The command to use

            Note: pNotify uses HTML (commented below), chat uses special codes.
        ]]
        --IncomingCallMessage = "<b>Incoming Call!</b><br/>Location: {location}<br/>Description: {description}<br/>Use command /r911 <b>{callId}</b> to respond!",
        IncomingCallMessage = "Incoming call from ^*{caller}^r! Location: ^3{location}^0 Description: ^3{description}^0 - Use /{command} ^*{callId}^r to respond!",

        --[[
            unitDutyMethod: How to detect if units are online?
                incad: units must be logged into the CAD
                permissions: units must have the "sonorancad.dispatchnotify" ACE permission (see docs)
                esxjob: requires esxsupport plugin, use jobs instead for on duty detection
                custom: Use custom function (defined below as unitDutyCustom)
        ]]
        UnitDutyMethod = "incad",

        --[[
            esxJobsAllowed: What jobs should count as being on duty?
        ]]
        EsxJobsAllowed = {
            ["police"] = true,
            ["ambulance"] = true,
            ["fire"] = true
        },

        --[[
            waypointType: Type of waypoint to use when officer is attached
                postal: set gps to caller's postal (less accurate, more realistic) - REQUIRES CONFIGURED POSTAL PLUGIN
                exact: set gps to caller's position (less realistic)
                none: disable waypointing
        ]]
        WaypointType = "postal",

        --[[
            waypointFallbackEnabled: Fall back to postal if exact coordinates cannot be found (for self-generated calls)
        ]]
        WaypointFallbackEnabled = true,
        --[[
            callTitle: Customize the title of a call made
        ]]
        CallTitle = "OFFICER RESPONSE",
        --[[
            sendNotesToUnits: Whether the script will fire events related to call notes.
        ]]
        SendNotesToUnits = true,
        --[[
            noteNotifyMethod:
                chat: send new notes via chat
                pnotify: send new notes via a pNotify popup (requires pNotify resource)
                custom: fire a client-side event that your script will consume (each active unit gets SonoranCAD::dispatchnotify:NewCallNote with an object containing callId and note)
        ]]
        NoteNotifyMethod = "chat",
        --[[
            noteMessage: Message to send to officers when a note is added, using the placeholders:
                {callid} - the call ID
                {note} - the note added
        ]]
        NoteMessage = "New note added for call ^*{callid}^r: {note}",
        --[[
            enableAddNote: Whether or not to enable the addnote command, allowing units attached to calls to add notes to their call.
        ]]
        EnableAddNote = true,
        --[[
            addNoteCommand: The command to create for adding notes.
        ]]
        AddNoteCommand = "addnote",
        --[[
            enableAddPlate: Enable the addplate command, allowing units to send locked plate data as a note to their current call. Will require the wraithv2 plugin to work.
        ]]
        EnableAddPlate = true,
        --[[
            addPlateCommand: The command to create for sending plate data
        ]]
        AddPlateCommand = "addplate",

        --[[
            onSceneHandler: Enables automatically disabling waypointing when marked on scene
        ]]
        OnSceneHandler = true,

        --[[
            onSceneIndex: Usually don't have to touch this. Controls which button is "on scene"
        ]]
        OnSceneIndex = 4
    },

    -- Previously civintegration
    CivSystem = {

    },

    ForceReg = {

    },
    Lookups = {

    },
    Radar = {

    },
    SonoranRadio = {

    }
    TrafficStop = {

    },
    UnitStatus = {

    }
}