# API Check

This simple plugin exposes a check to see if an API ID exists. This is useful if you want to inform players they need to create an account on the CAD.

## Usage

### Function
Callback output parameter: true/false if API ID exists.

```lua
cadApiIdExists("identifier_here", callback)
```

#### Example

```lua
cadApiIdExists("steam:1234567890", function(exists)
    if exists then
        print("API ID exists!")
    else
        print("API ID does not exist!")
    end
end)
```

### Event

This is a _server only_ event.

**Event Name:** SonoranCAD::apicheck:CheckPlayerLinked

**Response Event:** SonoranCAD::apicheck:CheckPlayerLinkedResponse

#### Example

```lua

-- Request
TriggerEvent("SonoranCAD::apicheck:CheckPlayerLinked", source, identifier)

-- Response
AddEventHandler("SonoranCAD::apicheck:CheckPlayerLinkedResponse", function(player, identifier, exists)
    print(("Player %s has API ID? %s"):format(player, exists))
end)
```