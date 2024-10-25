/*
  SonoranCAD FiveM - A SonoranCAD integration for FiveM servers
   Copyright (C) 2020  Sonoran Software

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program in the file "LICENSE".  If not, see <http://www.gnu.org/licenses/>.
*/
const fs = require('fs');
const path = require('path');
const { TeamSpeak, QueryProtocol } = require("ts3-nodejs-library");
const configFilePath = path.join(__dirname, "../../configuration/ts3integration_config.json");
const distFilePath = path.join(__dirname, "../../configuration/ts3integration_config.dist.json");
var clientsToAdd = [];
var clientsToRemove = [];

// cache units - they might get removed before we process them
var UnitCache = new Map();

// Load the configuration
function loadConfig() {
    if (fs.existsSync(configFilePath)) {
        // If config file exists, load it
        return require(configFilePath);
    } else if (fs.existsSync(distFilePath)) {
        console.log(`[INFO] TS3 Integration: Configuration file not found, falling back to dist file.`);
        // If dist file exists, attempt to rename it
        try {
            fs.renameSync(distFilePath, configFilePath);
            return require(configFilePath); // Load the renamed file
        } catch (error) {
            console.log(`[ERROR] TS3 Integration: Could not rename dist file to config file. Loading dist file as fallback.`);
            return require(distFilePath); // Load dist file as a fallback
        }
    } else {
        console.log(`[CRITICAL] TS3 Integration: Configuration file not found. No fallback available. Checked paths: ${configFilePath}, ${distFilePath}`);
    }
}

// Load the configuration
const ts3config = loadConfig();


// Check if the config values are set, or if we should use the server convars
const ts3UserConvar = GetConvar("sonorants3_server_user", 'false');
const ts3PassConvar = GetConvar("sonorants3_server_pass", 'false');
const ts3HostConvar = GetConvar("sonorants3_server_host", 'false');
const ts3PortConvar = GetConvar("sonorants3_server_port", 'false');
const ts3QPortConvar = GetConvar("sonorants3_server_qport", 'false');
if (ts3UserConvar != 'false') {
    ts3config.ts3server_user = ts3UserConvar;
    emit("SonoranCAD::core:writeLog", "info", "TS3 Integration: Using convar for ts3server_user instead of config value")
}
if (ts3PassConvar != 'false') {
    ts3config.ts3server_pass = ts3PassConvar;
    emit("SonoranCAD::core:writeLog", "info", "TS3 Integration: Using convar for ts3server_pass instead of config value")
}
if (ts3HostConvar != 'false') {
    ts3config.ts3server_host = ts3HostConvar;
    emit("SonoranCAD::core:writeLog", "info", "TS3 Integration: Using convar for ts3server_host instead of config value")
}
if (ts3PortConvar != 'false') {
    ts3config.ts3server_port = ts3PortConvar;
    emit("SonoranCAD::core:writeLog", "info", "TS3 Integration: Using convar for ts3server_port instead of config value")
}
if (ts3QPortConvar != 'false') {
    ts3config.ts3server_qport = ts3QPortConvar;
    emit("SonoranCAD::core:writeLog", "info", "TS3 Integration: Using convar for ts3server_qport instead of config value")
}


on('SonoranCAD::pushevents:UnitLogin', function (unit) {
    for (let apiId of unit.data.apiIds) {
        if (apiId.includes("=")) {
            clientsToAdd.push(apiId);
            UnitCache.set(unit.id, apiId);
            let i = clientsToRemove.indexOf(apiId);
            if (i > -1) {
                clientsToRemove.splice(i, 1);
            }
        }

    }
});

on('SonoranCAD::pushevents:UnitLogout', function (id) {
    let apiid = UnitCache.get(id);
    if (apiid != undefined) {
        clientsToRemove.push(apiid);
        UnitCache.delete(id);
    } else {
        emit("SonoranCAD::core:writeLog", "debug", `TS3 Integration Error: Could not find matching unit: ${id} not found`);
    }
});

setInterval(() => {
    if (clientsToRemove.length > 0) {
        TeamSpeak.connect({
            host: ts3config.ts3server_host,
            queryport: Number(ts3config.ts3server_qport),
            serverport: Number(ts3config.ts3server_port),
            protocol: QueryProtocol.RAW,
            username: ts3config.ts3server_user,
            password: ts3config.ts3server_pass,
            nickname: "SonoranCAD Integration"
        }).then(async teamspeak => {
            //retrieve the server group
            const sGroup = await teamspeak.getServerGroupByName(ts3config.onduty_servergroup);
            if (!sGroup) {
                emit("SonoranCAD::core:writeLog", "error", "TS3 Integration Error: Unable to locate server group. Ensure onduty_servergroup is set.");
                clientsToRemove = [];
                return;
            }
            for (let id of clientsToRemove) {
                let client = await teamspeak.getClientByUid(id);
                if (!client) {
                    emit("SonoranCAD::core:writeLog", "warn", "Was unable to locate client with ID " + id);
                } else {
                    // get name of channel client is in
                    let channel = await teamspeak.getChannelById(client.cid);
                    emit("SonoranCAD::core:writeLog", "debug", `Client is in channel ID ${client.cid}, which is named ${channel.name}`);
                    if (ts3config.enforced_channels.includes(channel.name)) {
                        await teamspeak.clientKick(client, 4, "Went off duty", true);
                    } else {
                        emit("SonoranCAD::core:writeLog", "debug", `Channel ${channel.name} is not in enforced list, which is: ${JSON.stringify(ts3config.enforced_channels)}`);
                    }
                    await teamspeak.clientDelServerGroup(client, sGroup);
                    emit("SonoranCAD::core:writeLog", "debug", "Removing " + client.nickname + " from onduty group " + ts3config.onduty_servergroup);
                }
            }
            clientsToRemove = [];
            await teamspeak.quit();
        }).catch(e => {
            emit("SonoranCAD::core:writeLog", "error", "TS3 Integration Error: " + e);
            clientsToRemove = [];
        })
    }
}, ts3config.logoutGraceTime)

setInterval(() => {
    if (clientsToAdd.length > 0) {
        TeamSpeak.connect({
            host: ts3config.ts3server_host,
            queryport: Number(ts3config.ts3server_qport),
            serverport: Number(ts3config.ts3server_port),
            protocol: QueryProtocol.RAW,
            username: ts3config.ts3server_user,
            password: ts3config.ts3server_pass,
            nickname: "SonoranCAD Integration"
        }).then(async teamspeak => {
            //retrieve the server group
            const sGroup = await teamspeak.getServerGroupByName(ts3config.onduty_servergroup);
            if (!sGroup) {
                emit("SonoranCAD::core:writeLog", "error", "TS3 Integration Error: Unable to locate server group. Ensure onduty_servergroup is set.");
                clientsToAdd = [];
                return;
            }
            for (let id of clientsToAdd) {
                let client = await teamspeak.getClientByUid(id);
                if (!client) {
                    emit("SonoranCAD::core:writeLog", "warn", "Was unable to locate client with ID " + id);
                } else {
                    await teamspeak.clientAddServerGroup(client, sGroup);
                    emit("SonoranCAD::core:writeLog", "debug", "Adding " + client.nickname + " to onduty group " + ts3config.onduty_servergroup);
                }
            }
            clientsToAdd = [];
            await teamspeak.quit();
        }).catch(e => {
            emit("SonoranCAD::core:writeLog", "error", "TS3 Integration Error: " + e);
            clientsToAdd = [];
        })
    }
}, ts3config.loginGraceTime)