# Unit Status Plugin

This plugin allows you to change a unit's status in the CAD.

## Usage

### Function

This is a server-side function only and is exported as `cadSetUnitStatus`. Use `setUnitStatus` if using with other plugins.

```lua
cadSetUnitStatus(<apiId>, <status>, [player])
```

- apiId: The identifier attached to the unit
- status: A status, can be the actual string or a number, based on configuration
= player (optional): server ID of the player, used to send a client event

### Event

**README is work-in-progress. See `cl_unitstatus.lua` for example usage with events.**

## Command Usage

Script provides a status set command by default. Players will need the `command.setstatus` ACE permission (or whatever you configure the command to be).