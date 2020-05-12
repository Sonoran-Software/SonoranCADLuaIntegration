# TrafficStop

## Commands Implemented

| Command | Description                                               |
|---------|-----------------------------------------------------------|
| ts      | Send a new dispatch to dispatch regarding the TS          |


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