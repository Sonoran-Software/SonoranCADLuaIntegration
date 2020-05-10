# CallCommands

## Commands Implemented

| Command | Description                                 |
|---------|---------------------------------------------|
| 911     | Sends specific 911 call to the CAD          |
| 511     | Sends specific 511 call to the CAD (Civil)  |
| 311     | Sends non-emergency call to the CAD (Civil) |

## Custom Events

```
 EVENT: cadIncomingCall
 PARAMS:
      emergency = true/false (911 or 311 call)
      caller = name of caller
      location = street / cross street string
      description = description of call
      source = playerId
```