# Streaming Game Assets
Sonoran Lua Framework supports streaming game assets with plugins.

Simply bundle a stream folder with your plugin releases in order to have the plugin updater properly keep the stream folder up to date.

The Plugin folder in your Git repo needs to have the following base folder structure...

```
/{plugin_name}/(plugin code, version and config files)
/{plugin_name}/stream/(assets here)
/readme.md (optional)
```

When installing your plugin for the first time the stream folder should be manually moved to the `[sonorancad]/sonorancad/` directory and merged with existing files you may have.

Each plugin will have its own subfolder within the stream folder with the plugin name as the subdirectory name.

For example: `[sonorancad]/sonorancad/stream/smartsigns/(assets)`

This ensures that the plugin updator will be able to update the streaming asset files, both removing old assets and adding new ones.
