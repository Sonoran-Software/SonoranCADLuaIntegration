# TrafficStop

## Commands Implemented

| Command | Description                                               |
|---------|-----------------------------------------------------------|
| ts      | Send a new dispatch to dispatch regarding the TS          |


## Custom Events

```
 EVENT: cadIncomingTraffic
 PARAMS:
      origin =(1 = CALLER / 2 = RADIO DISPATCH / 3 = OBSERVED / 4 = WALK_UP
      status = 1 = PENDING / 2 = ACTIVE / 3 = CLOSED
      priority = 1, 2, or 3
      title = Title that will appear in CAD
      code = 10 code that will be used for the new dispatch
      address = street / cross street string
      description = description of Traffic Stop
      source = playerId
```