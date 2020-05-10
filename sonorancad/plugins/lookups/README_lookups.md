# Lookups

Implements name and plate lookups via the CAD.

**NOTICE**: Use of this plugin requires a **Plus** SonoranCAD subscription!

## Exported Functions

NOTE: For return object definitions, see the [Developer Documentation](https://info.sonorancad.com/sonoran-cad/api-integration/api-endpoints/lookup-name-or-plate).

| Function       | Arguments                          | Description                                            | Returns                                                       |
|----------------|------------------------------------|--------------------------------------------------------|---------------------------------------------------------------|
| cadNameLookup  | FirstName, MiddleInitial, LastName | Looks up a character based on the arguments specified. | Objects containing character data and all associated objects. |
| cadPlateLookup | plate                              | Looks up a vehicle based on specified plate number.    | Objects containing vehicle data and all associated objects.   |

## For Developers

This plugin also adds the commands `namefind` and `platefind` which takes the above arguments and prints the returned JSON object to the console.