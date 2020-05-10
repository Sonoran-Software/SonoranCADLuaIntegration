# Postals Plugin

## Using Nearest-Postal

If you're using the [nearest postals script publicly available](https://forum.cfx.re/t/release-nearest-postal-script/293511), you must add the following code to the bottom of `cl.lua`:

```lua
exports('getPostal', function() return postals[nearest.i].code end)
```

After doing so, set the configuration option to "nearestpostal".

## Custom Postal Scripts

If you specify "custom", you must edit the `getPostalCustom` function found in `config_postals.lua` to return a postal code as a string.