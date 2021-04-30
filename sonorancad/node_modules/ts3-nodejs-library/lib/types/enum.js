"use strict";
/**
 * TeamSpeak Enums
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.VirtualServerStatus = exports.ApiKeyScope = exports.ClientType = exports.TokenType = exports.PermissionGroupTypes = exports.PermissionGroupDatabaseTypes = exports.ReasonIdentifier = exports.LogLevel = exports.TextMessageTargetMode = exports.CodecEncryptionMode = exports.Codec = exports.HostBannerMode = exports.HostMessageMode = void 0;
var HostMessageMode;
(function (HostMessageMode) {
    /** don't display anything */
    HostMessageMode[HostMessageMode["NONE"] = 0] = "NONE";
    /** display message in chatlog */
    HostMessageMode[HostMessageMode["LOG"] = 1] = "LOG";
    /** display message in modal dialog */
    HostMessageMode[HostMessageMode["MODAL"] = 2] = "MODAL";
    /** display message in modal dialog and close connection */
    HostMessageMode[HostMessageMode["MODALQUIT"] = 3] = "MODALQUIT";
})(HostMessageMode = exports.HostMessageMode || (exports.HostMessageMode = {}));
var HostBannerMode;
(function (HostBannerMode) {
    /** do not adjust */
    HostBannerMode[HostBannerMode["NOADJUST"] = 0] = "NOADJUST";
    /** adjust but ignore aspect ratio (like TeamSpeak 2) */
    HostBannerMode[HostBannerMode["IGNOREASPECT"] = 1] = "IGNOREASPECT";
    /** adjust and keep aspect ratio */
    HostBannerMode[HostBannerMode["KEEPASPECT"] = 2] = "KEEPASPECT";
})(HostBannerMode = exports.HostBannerMode || (exports.HostBannerMode = {}));
var Codec;
(function (Codec) {
    /** speex narrowband (mono, 16bit, 8kHz) */
    Codec[Codec["SPEEX_NARROWBAND"] = 0] = "SPEEX_NARROWBAND";
    /** speex wideband (mono, 16bit, 16kHz) */
    Codec[Codec["SPEEX_WIDEBAND"] = 1] = "SPEEX_WIDEBAND";
    /** speex ultra-wideband (mono, 16bit, 32kHz) */
    Codec[Codec["SPEEX_ULTRAWIDEBAND"] = 2] = "SPEEX_ULTRAWIDEBAND";
    /** celt mono (mono, 16bit, 48kHz) */
    Codec[Codec["CELT_MONO"] = 3] = "CELT_MONO";
    Codec[Codec["OPUS_VOICE"] = 4] = "OPUS_VOICE";
    Codec[Codec["OPUS_MUSIC"] = 5] = "OPUS_MUSIC";
})(Codec = exports.Codec || (exports.Codec = {}));
var CodecEncryptionMode;
(function (CodecEncryptionMode) {
    /** configure per channel */
    CodecEncryptionMode[CodecEncryptionMode["INDIVIDUAL"] = 0] = "INDIVIDUAL";
    /** globally disabled */
    CodecEncryptionMode[CodecEncryptionMode["DISABLED"] = 1] = "DISABLED";
    /** globally enabled */
    CodecEncryptionMode[CodecEncryptionMode["ENABLED"] = 2] = "ENABLED";
})(CodecEncryptionMode = exports.CodecEncryptionMode || (exports.CodecEncryptionMode = {}));
var TextMessageTargetMode;
(function (TextMessageTargetMode) {
    /** target is a client */
    TextMessageTargetMode[TextMessageTargetMode["CLIENT"] = 1] = "CLIENT";
    /** target is a channel */
    TextMessageTargetMode[TextMessageTargetMode["CHANNEL"] = 2] = "CHANNEL";
    /** target is a virtual server */
    TextMessageTargetMode[TextMessageTargetMode["SERVER"] = 3] = "SERVER";
})(TextMessageTargetMode = exports.TextMessageTargetMode || (exports.TextMessageTargetMode = {}));
var LogLevel;
(function (LogLevel) {
    /** everything that is really bad */
    LogLevel[LogLevel["ERROR"] = 1] = "ERROR";
    /** everything that might be bad */
    LogLevel[LogLevel["WARNING"] = 2] = "WARNING";
    /** output that might help find a problem */
    LogLevel[LogLevel["DEBUG"] = 3] = "DEBUG";
    /** informational output */
    LogLevel[LogLevel["INFO"] = 4] = "INFO";
})(LogLevel = exports.LogLevel || (exports.LogLevel = {}));
var ReasonIdentifier;
(function (ReasonIdentifier) {
    /** kick client from channel */
    ReasonIdentifier[ReasonIdentifier["KICK_CHANNEL"] = 4] = "KICK_CHANNEL";
    /** kick client from server */
    ReasonIdentifier[ReasonIdentifier["KICK_SERVER"] = 5] = "KICK_SERVER";
})(ReasonIdentifier = exports.ReasonIdentifier || (exports.ReasonIdentifier = {}));
var PermissionGroupDatabaseTypes;
(function (PermissionGroupDatabaseTypes) {
    /** template group (used for new virtual servers) */
    PermissionGroupDatabaseTypes[PermissionGroupDatabaseTypes["Template"] = 0] = "Template";
    /** regular group (used for regular clients) */
    PermissionGroupDatabaseTypes[PermissionGroupDatabaseTypes["Regular"] = 1] = "Regular";
    /** global query group (used for ServerQuery clients) */
    PermissionGroupDatabaseTypes[PermissionGroupDatabaseTypes["Query"] = 2] = "Query";
})(PermissionGroupDatabaseTypes = exports.PermissionGroupDatabaseTypes || (exports.PermissionGroupDatabaseTypes = {}));
var PermissionGroupTypes;
(function (PermissionGroupTypes) {
    /** server group permission */
    PermissionGroupTypes[PermissionGroupTypes["ServerGroup"] = 0] = "ServerGroup";
    /** client specific permission */
    PermissionGroupTypes[PermissionGroupTypes["GlobalClient"] = 1] = "GlobalClient";
    /** channel specific permission */
    PermissionGroupTypes[PermissionGroupTypes["Channel"] = 2] = "Channel";
    /** channel group permission */
    PermissionGroupTypes[PermissionGroupTypes["ChannelGroup"] = 3] = "ChannelGroup";
    /** channel-client specific permission */
    PermissionGroupTypes[PermissionGroupTypes["ChannelClient"] = 4] = "ChannelClient";
})(PermissionGroupTypes = exports.PermissionGroupTypes || (exports.PermissionGroupTypes = {}));
var TokenType;
(function (TokenType) {
    /** server group token (id1={groupID} id2=0) */
    TokenType[TokenType["ServerGroup"] = 0] = "ServerGroup";
    /** channel group token (id1={groupID} id2={channelID}) */
    TokenType[TokenType["ChannelGroup"] = 1] = "ChannelGroup";
})(TokenType = exports.TokenType || (exports.TokenType = {}));
var ClientType;
(function (ClientType) {
    ClientType[ClientType["Regular"] = 0] = "Regular";
    ClientType[ClientType["ServerQuery"] = 1] = "ServerQuery";
})(ClientType = exports.ClientType || (exports.ClientType = {}));
var ApiKeyScope;
(function (ApiKeyScope) {
    ApiKeyScope["MANAGE"] = "manage";
    ApiKeyScope["READ"] = "read";
    ApiKeyScope["WRITE"] = "write";
})(ApiKeyScope = exports.ApiKeyScope || (exports.ApiKeyScope = {}));
var VirtualServerStatus;
(function (VirtualServerStatus) {
    VirtualServerStatus["UNKNOWN"] = "unknown";
    /* the virtual server is running and clients can connect */
    VirtualServerStatus["ONLINE"] = "online";
    /* the virtual server is not running */
    VirtualServerStatus["OFFLINE"] = "offline";
    /* the virtual server is currently starting */
    VirtualServerStatus["BOOTING_UP"] = "booting up";
    /* the virtual server is currently shutting down */
    VirtualServerStatus["SHUTTING_DOWN"] = "shutting down";
    /* the virtual server is currently deploying a snapshot */
    VirtualServerStatus["DEPLOY_RUNNING"] = "deploy running";
    /* the virtual server is running *isolated* and clients cannot connect */
    VirtualServerStatus["ONLINE_VIRTUAL"] = "online virtual";
    /* the virtual server is running in another TeamSpeak instance */
    VirtualServerStatus["OTHER_INSTANCE"] = "other instance";
})(VirtualServerStatus = exports.VirtualServerStatus || (exports.VirtualServerStatus = {}));
//# sourceMappingURL=enum.js.map