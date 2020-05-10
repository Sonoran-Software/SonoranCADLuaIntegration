# WraithV2 Plugin

This plugin is mostly a proof of concept for automated plate reading.

## Required Configuration

Use of this plugin requires the [Wraith ARS 2X](https://forum.cfx.re/t/release-wraith-ars-2x-police-radar-and-plate-reader-v1-2-4/1058277) radar and plate reader to function.

You will **also** need to edit the code in the resource for this plate reader to be useful.

**FIND** the following line in `cl_plate_reader.lua`:

```lua
TriggerServerEvent( "wk:onPlateScanned", cam, plate, index )
```

**REPLACE** the above with the following:

```lua
if IsPlayerInAnySeat(veh) or IsVehiclePreviouslyOwnedByPlayer(veh) then
    TriggerServerEvent( "wk:onPlateScanned", cam, plate, index )
end
```

**FIND** the following line in `cl_plate_reader.lua`:

```lua
RegisterNetEvent("RADAR:PingBoloPlate")
```

**ADD** the following lines **ABOVE** the line you found:

```lua
function IsPlayerInAnySeat(veh)
	local hasPlayer = false
	for i = -1, GetVehicleMaxNumberOfPassengers(veh)+1, 1 do
		local ped = GetPedInVehicleSeat(veh, i)
		if ped then
			if IsPedAPlayer(ped) then
				hasPlayer = true
			end
		end
	end
	return hasPlayer
end
```