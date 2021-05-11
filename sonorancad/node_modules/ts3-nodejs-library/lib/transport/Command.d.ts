import { ResponseError } from "../exception/ResponseError";
import { TeamSpeakQuery } from "./TeamSpeakQuery";
import { Version } from "../types/ResponseTypes";
export declare class Command {
    static SNAKE_CASE_IDENTIFIER: string;
    private requestParser;
    private responseParser;
    private cmd;
    private options;
    private multiOpts;
    private flags;
    private response;
    private error;
    private stack;
    /** Initializes the Respone with default values */
    reset(): Command;
    /** Sets the main command to send */
    setCommand(cmd: string): Command;
    /**
     * Sets the TeamSpeak Key Value Pairs
     * @param opts sets the Object with the key value pairs which should get sent to the TeamSpeak Query
     */
    setOptions(options: Command.options): Command;
    /**
     * retrieves the current set options for this command
     */
    getOptions(): Command.options;
    /**
     * Sets the TeamSpeak Key Value Pairs
     * @param opts sets the Object with the key value pairs which should get sent to the TeamSpeak Query
     */
    setMultiOptions(options: Command.multiOpts): Command;
    /**
     * adds a customparser
     * @param parsers
     */
    setParser(parsers: Command.ParserCallback): this;
    /** checks wether there are options used with this command */
    hasOptions(): boolean;
    /** checks wether there are options used with this command */
    hasMultiOptions(): boolean;
    /**
     * set TeamSpeak flags
     * @param flags sets the flags which should get sent to the teamspeak query
     */
    setFlags(flags: Command.flags): Command;
    /** checks wether there are flags used with this command */
    hasFlags(): boolean;
    /**
     * set the Line which has been received from the TeamSpeak Query
     * @param line the line which has been received from the teamSpeak query
     */
    setResponse(line: string): Command;
    /**
     * Set the error line which has been received from the TeamSpeak Query
     * @param error the error line which has been received from the TeamSpeak Query
     */
    setError(raw: string): Command;
    /** get the parsed error object which has been received from the TeamSpeak Query */
    getError(): ResponseError | null;
    /** checks if a error has been received */
    hasError(): boolean;
    /** get the parsed response object which has been received from the TeamSpeak Query */
    getResponse(): TeamSpeakQuery.Response;
    /** runs the parser of this instance */
    parse(raw: string): TeamSpeakQuery.Response;
    /** runs the parser of this instance */
    build(): string;
    /**
     * retrieves the default parsers
     */
    static getParsers(): Command.Parsers;
    /**
     * parses a snapshot create request
     * @param param0 the custom snapshot response parser
     */
    static parseSnapshotCreate({ raw }: Pick<Command.ParserArgument, "raw">): TeamSpeakQuery.Response;
    /**
     * the custom snapshot request parser
     * @param data snapshot string
     * @param cmd command object
     */
    static buildSnapshotDeploy(data: string, cmd: Command, { version }: Version, snapshotVersion?: string): string;
    /**
     * checks if a version string has a minimum of x
     * @param minimum minimum the version string should have
     * @param version version string to compare
     */
    static minVersion(minimum: string, version: string): boolean;
    /**
     * parses a query response
     * @param data the query response received
     */
    static parse({ raw }: Pick<Command.ParserArgument, "raw">): TeamSpeakQuery.Response;
    /**
     * Checks if a error has been received
     * @return The parsed String which is readable by the TeamSpeak Query
     */
    static build(command: Command): string;
    /**
     * builds the query string for options
     * @return the parsed String which is readable by the TeamSpeak Querytt
     */
    buildOptions(): string;
    /** builds the query string for options */
    buildOption(options: Record<string, any>): string;
    /** builds the query string for flags */
    buildFlags(): string;
    /**
     * escapes a key value pair
     * @param {string} key the key used
     * @param {string|string[]} value the value or an array of values
     * @return the parsed String which is readable by the TeamSpeak Query
     */
    static escapeKeyValue(key: string, value: string | string[] | boolean): string;
    /**
     * retrieves the key value pair from a string
     * @param str the key value pair to unescape eg foo=bar
     */
    static getKeyValue(str: string): {
        key: string;
        value: string | undefined;
    };
    /**
     * Parses a value to the type which the key represents
     * @param k the key which should get looked up
     * @param v the value which should get parsed
     */
    static parseValue(k: string, v: string | undefined): any;
    /**
     * parses a number
     * @param value string to parse
     */
    static parseBoolean(value: string): boolean;
    /**
     * parses a string value
     * @param value string to parse
     */
    static parseString(value: string): string;
    static parseRecursive(value: string): TeamSpeakQuery.Response;
    /**
     * parses a string array
     * @param value string to parse
     */
    static parseStringArray(value: string): string[];
    /**
     * parses a number
     * @param value string to parse
     */
    static parseNumber(value: string): number;
    /**
     * parses a number array
     * @param value string to parse
     */
    static parseNumberArray(value: string): number[];
    /** unescapes a string */
    static unescape(str: string): string;
    /** escapes a string */
    static escape(str: string): string;
    /** converts a string to camel case */
    static toCamelCase(str: string): string;
    /** converts a string to snake case */
    static toSnakeCase(str: string): string;
}
export declare namespace Command {
    interface ParserArgument {
        cmd: typeof Command;
        raw: string;
    }
    interface Parsers {
        response: ResponseParser;
        request: RequestParser;
    }
    type ParserCallback = (parser: Parsers) => Parsers;
    type ResponseParser = (data: ParserArgument) => TeamSpeakQuery.Response;
    type RequestParser = (cmd: Command) => string;
    type options = Record<string, TeamSpeakQuery.ValueTypes>;
    type multiOpts = Command.options[];
    type flags = (number | string | null)[];
    const Identifier: {
        sid: typeof Command.parseString;
        serverId: typeof Command.parseString;
        virtualserverNickname: typeof Command.parseString;
        virtualserverUniqueIdentifier: typeof Command.parseString;
        virtualserverName: typeof Command.parseString;
        virtualserverWelcomemessage: typeof Command.parseString;
        virtualserverPlatform: typeof Command.parseString;
        virtualserverVersion: typeof Command.parseString;
        virtualserverMaxclients: typeof Command.parseNumber;
        virtualserverPassword: typeof Command.parseString;
        virtualserverClientsonline: typeof Command.parseNumber;
        virtualserverChannelsonline: typeof Command.parseNumber;
        virtualserverCreated: typeof Command.parseNumber;
        virtualserverUptime: typeof Command.parseNumber;
        virtualserverCodecEncryptionMode: typeof Command.parseNumber;
        virtualserverHostmessage: typeof Command.parseString;
        virtualserverHostmessageMode: typeof Command.parseNumber;
        virtualserverFilebase: typeof Command.parseString;
        virtualserverDefaultServerGroup: typeof Command.parseString;
        virtualserverDefaultChannelGroup: typeof Command.parseString;
        virtualserverFlagPassword: typeof Command.parseBoolean;
        virtualserverDefaultChannelAdminGroup: typeof Command.parseString;
        virtualserverMaxDownloadTotalBandwidth: typeof Command.parseNumber;
        virtualserverMaxUploadTotalBandwidth: typeof Command.parseNumber;
        virtualserverHostbannerUrl: typeof Command.parseString;
        virtualserverHostbannerGfxUrl: typeof Command.parseString;
        virtualserverHostbannerGfxInterval: typeof Command.parseNumber;
        virtualserverComplainAutobanCount: typeof Command.parseNumber;
        virtualserverComplainAutobanTime: typeof Command.parseNumber;
        virtualserverComplainRemoveTime: typeof Command.parseNumber;
        virtualserverMinClientsInChannelBeforeForcedSilence: typeof Command.parseNumber;
        virtualserverPrioritySpeakerDimmModificator: typeof Command.parseNumber;
        virtualserverId: typeof Command.parseString;
        virtualserverAntifloodPointsNeededPluginBlock: typeof Command.parseNumber;
        virtualserverAntifloodPointsTickReduce: typeof Command.parseNumber;
        virtualserverAntifloodPointsNeededCommandBlock: typeof Command.parseNumber;
        virtualserverAntifloodPointsNeededIpBlock: typeof Command.parseNumber;
        virtualserverClientConnections: typeof Command.parseNumber;
        virtualserverQueryClientConnections: typeof Command.parseNumber;
        virtualserverHostbuttonTooltip: typeof Command.parseString;
        virtualserverHostbuttonUrl: typeof Command.parseString;
        virtualserverHostbuttonGfxUrl: typeof Command.parseString;
        virtualserverQueryclientsonline: typeof Command.parseNumber;
        virtualserverDownloadQuota: typeof Command.parseNumber;
        virtualserverUploadQuota: typeof Command.parseNumber;
        virtualserverMonthBytesDownloaded: typeof Command.parseNumber;
        virtualserverMonthBytesUploaded: typeof Command.parseNumber;
        virtualserverTotalBytesDownloaded: typeof Command.parseNumber;
        virtualserverTotalBytesUploaded: typeof Command.parseNumber;
        virtualserverPort: typeof Command.parseNumber;
        virtualserverAutostart: typeof Command.parseNumber;
        virtualserverMachineId: typeof Command.parseString;
        virtualserverNeededIdentitySecurityLevel: typeof Command.parseNumber;
        virtualserverLogClient: typeof Command.parseNumber;
        virtualserverLogQuery: typeof Command.parseNumber;
        virtualserverLogChannel: typeof Command.parseNumber;
        virtualserverLogPermissions: typeof Command.parseNumber;
        virtualserverLogServer: typeof Command.parseNumber;
        virtualserverLogFiletransfer: typeof Command.parseNumber;
        virtualserverMinClientVersion: typeof Command.parseNumber;
        virtualserverNamePhonetic: typeof Command.parseString;
        virtualserverIconId: typeof Command.parseString;
        virtualserverReservedSlots: typeof Command.parseNumber;
        virtualserverTotalPacketlossSpeech: typeof Command.parseNumber;
        virtualserverTotalPacketlossKeepalive: typeof Command.parseNumber;
        virtualserverTotalPacketlossControl: typeof Command.parseNumber;
        virtualserverTotalPacketlossTotal: typeof Command.parseNumber;
        virtualserverTotalPing: typeof Command.parseNumber;
        virtualserverIp: typeof Command.parseStringArray;
        virtualserverWeblistEnabled: typeof Command.parseNumber;
        virtualserverAskForPrivilegekey: typeof Command.parseNumber;
        virtualserverHostbannerMode: typeof Command.parseNumber;
        virtualserverChannelTempDeleteDelayDefault: typeof Command.parseNumber;
        virtualserverMinAndroidVersion: typeof Command.parseNumber;
        virtualserverMinIosVersion: typeof Command.parseNumber;
        virtualserverStatus: typeof Command.parseString;
        connectionFiletransferBandwidthSent: typeof Command.parseNumber;
        connectionFiletransferBandwidthReceived: typeof Command.parseNumber;
        connectionFiletransferBytesSentTotal: typeof Command.parseNumber;
        connectionFiletransferBytesReceivedTotal: typeof Command.parseNumber;
        connectionPacketsSentSpeech: typeof Command.parseNumber;
        connectionBytesSentSpeech: typeof Command.parseNumber;
        connectionPacketsReceivedSpeech: typeof Command.parseNumber;
        connectionBytesReceivedSpeech: typeof Command.parseNumber;
        connectionPacketsSentKeepalive: typeof Command.parseNumber;
        connectionBytesSentKeepalive: typeof Command.parseNumber;
        connectionPacketsReceivedKeepalive: typeof Command.parseNumber;
        connectionBytesReceivedKeepalive: typeof Command.parseNumber;
        connectionPacketsSentControl: typeof Command.parseNumber;
        connectionBytesSentControl: typeof Command.parseNumber;
        connectionPacketsReceivedControl: typeof Command.parseNumber;
        connectionBytesReceivedControl: typeof Command.parseNumber;
        connectionPacketsSentTotal: typeof Command.parseNumber;
        connectionBytesSentTotal: typeof Command.parseNumber;
        connectionPacketsReceivedTotal: typeof Command.parseNumber;
        connectionBytesReceivedTotal: typeof Command.parseNumber;
        connectionBandwidthSentLastSecondTotal: typeof Command.parseNumber;
        connectionBandwidthSentLastMinuteTotal: typeof Command.parseNumber;
        connectionBandwidthReceivedLastSecondTotal: typeof Command.parseNumber;
        connectionBandwidthReceivedLastMinuteTotal: typeof Command.parseNumber;
        connectionPacketlossTotal: typeof Command.parseNumber;
        connectionPing: typeof Command.parseNumber;
        clid: typeof Command.parseString;
        clientId: typeof Command.parseString;
        cldbid: typeof Command.parseString;
        clientDatabaseId: typeof Command.parseString;
        clientChannelId: typeof Command.parseString;
        clientOriginServerId: typeof Command.parseString;
        clientNickname: typeof Command.parseString;
        clientType: typeof Command.parseNumber;
        clientAway: typeof Command.parseBoolean;
        clientAwayMessage: typeof Command.parseString;
        clientFlagTalking: typeof Command.parseBoolean;
        clientInputMuted: typeof Command.parseBoolean;
        clientOutputMuted: typeof Command.parseBoolean;
        clientInputHardware: typeof Command.parseBoolean;
        clientOutputHardware: typeof Command.parseBoolean;
        clientTalkPower: typeof Command.parseNumber;
        clientIsTalker: typeof Command.parseBoolean;
        clientIsPrioritySpeaker: typeof Command.parseNumber;
        clientIsRecording: typeof Command.parseBoolean;
        clientIsChannelCommander: typeof Command.parseBoolean;
        clientUniqueIdentifier: typeof Command.parseString;
        clientServergroups: typeof Command.parseStringArray;
        clientChannelGroupId: typeof Command.parseString;
        clientChannelGroupInheritedChannelId: typeof Command.parseString;
        clientVersion: typeof Command.parseString;
        clientPlatform: typeof Command.parseString;
        clientIdleTime: typeof Command.parseNumber;
        clientCreated: typeof Command.parseNumber;
        clientLastconnected: typeof Command.parseNumber;
        clientIconId: typeof Command.parseString;
        clientCountry: typeof Command.parseString;
        clientEstimatedLocation: typeof Command.parseString;
        clientOutputonlyMuted: typeof Command.parseNumber;
        clientDefaultChannel: typeof Command.parseString;
        clientMetaData: typeof Command.parseString;
        clientVersionSign: typeof Command.parseString;
        clientSecurityHash: typeof Command.parseString;
        clientLoginName: typeof Command.parseString;
        clientLoginPassword: typeof Command.parseString;
        clientTotalconnections: typeof Command.parseNumber;
        clientFlagAvatar: typeof Command.parseString;
        clientTalkRequest: typeof Command.parseBoolean;
        clientTalkRequestMsg: typeof Command.parseString;
        clientMonthBytesUploaded: typeof Command.parseNumber;
        clientMonthBytesDownloaded: typeof Command.parseNumber;
        clientTotalBytesUploaded: typeof Command.parseNumber;
        clientTotalBytesDownloaded: typeof Command.parseNumber;
        clientNicknamePhonetic: typeof Command.parseString;
        clientDefaultToken: typeof Command.parseString;
        clientBadges: typeof Command.parseString;
        clientBase64HashClientUID: typeof Command.parseString;
        connectionConnectedTime: typeof Command.parseNumber;
        connectionClientIp: typeof Command.parseString;
        clientMyteamspeakId: typeof Command.parseString;
        clientIntegrations: typeof Command.parseString;
        clientDescription: typeof Command.parseString;
        clientNeededServerqueryViewPower: typeof Command.parseNumber;
        clientMyteamspeakAvatar: typeof Command.parseString;
        clientSignedBadges: typeof Command.parseString;
        clientLastip: typeof Command.parseString;
        cid: typeof Command.parseString;
        pid: typeof Command.parseString;
        cpid: typeof Command.parseString;
        order: typeof Command.parseNumber;
        channelOrder: typeof Command.parseNumber;
        channelName: typeof Command.parseString;
        channelPassword: typeof Command.parseString;
        channelDescription: typeof Command.parseString;
        channelTopic: typeof Command.parseString;
        channelFlagDefault: typeof Command.parseBoolean;
        channelFlagPassword: typeof Command.parseBoolean;
        channelFlagPermanent: typeof Command.parseBoolean;
        channelFlagSemiPermanent: typeof Command.parseBoolean;
        channelFlagTemporary: typeof Command.parseBoolean;
        channelCodec: typeof Command.parseNumber;
        channelCodecQuality: typeof Command.parseNumber;
        channelNeededTalkPower: typeof Command.parseNumber;
        channelIconId: typeof Command.parseString;
        totalClientsFamily: typeof Command.parseNumber;
        channelMaxclients: typeof Command.parseNumber;
        channelMaxfamilyclients: typeof Command.parseNumber;
        totalClients: typeof Command.parseNumber;
        channelNeededSubscribePower: typeof Command.parseNumber;
        channelCodecLatencyFactor: typeof Command.parseNumber;
        channelCodecIsUnencrypted: typeof Command.parseNumber;
        channelSecuritySalt: typeof Command.parseString;
        channelDeleteDelay: typeof Command.parseNumber;
        channelFlagMaxclientsUnlimited: typeof Command.parseBoolean;
        channelFlagMaxfamilyclientsUnlimited: typeof Command.parseBoolean;
        channelFlagMaxfamilyclientsInherited: typeof Command.parseBoolean;
        channelFilepath: typeof Command.parseString;
        channelForcedSilence: typeof Command.parseNumber;
        channelNamePhonetic: typeof Command.parseString;
        channelFlagPrivate: typeof Command.parseBoolean;
        channelBannerGfxUrl: typeof Command.parseString;
        channelBannerMode: typeof Command.parseNumber;
        secondsEmpty: typeof Command.parseNumber;
        cgid: typeof Command.parseString;
        sgid: typeof Command.parseString;
        permid: typeof Command.parseString;
        permvalue: typeof Command.parseNumber;
        permnegated: typeof Command.parseBoolean;
        permskip: typeof Command.parseBoolean;
        permsid: typeof Command.parseString;
        t: typeof Command.parseNumber;
        id1: typeof Command.parseString;
        id2: typeof Command.parseString;
        p: typeof Command.parseNumber;
        v: typeof Command.parseNumber;
        n: typeof Command.parseNumber;
        s: typeof Command.parseNumber;
        reasonid: typeof Command.parseString;
        reasonmsg: typeof Command.parseString;
        ctid: typeof Command.parseString;
        cfid: typeof Command.parseString;
        targetmode: typeof Command.parseNumber;
        target: typeof Command.parseNumber;
        invokerid: typeof Command.parseString;
        invokername: typeof Command.parseString;
        invokeruid: typeof Command.parseString;
        hash: typeof Command.parseString;
        lastPos: typeof Command.parseNumber;
        fileSize: typeof Command.parseNumber;
        l: typeof Command.parseString;
        path: typeof Command.parseString;
        size: typeof Command.parseNumber;
        clientftfid: typeof Command.parseString;
        serverftfid: typeof Command.parseString;
        currentSpeed: typeof Command.parseNumber;
        averageSpeed: typeof Command.parseNumber;
        runtime: typeof Command.parseNumber;
        sizedone: typeof Command.parseNumber;
        sender: typeof Command.parseNumber;
        status: typeof Command.parseNumber;
        ftkey: typeof Command.parseString;
        port: typeof Command.parseNumber;
        proto: typeof Command.parseNumber;
        datetime: typeof Command.parseNumber;
        hostTimestampUtc: typeof Command.parseNumber;
        instanceUptime: typeof Command.parseNumber;
        virtualserversRunningTotal: typeof Command.parseNumber;
        virtualserversTotalChannelsOnline: typeof Command.parseNumber;
        virtualserversTotalClientsOnline: typeof Command.parseNumber;
        virtualserversTotalMaxclients: typeof Command.parseNumber;
        serverinstanceDatabaseVersion: typeof Command.parseNumber;
        serverinstanceFiletransferPort: typeof Command.parseNumber;
        serverinstanceServerqueryMaxConnectionsPerIp: typeof Command.parseNumber;
        serverinstanceMaxDownloadTotalBandwidth: typeof Command.parseNumber;
        serverinstanceMaxUploadTotalBandwidth: typeof Command.parseNumber;
        serverinstanceGuestServerqueryGroup: typeof Command.parseNumber;
        serverinstancePendingConnectionsPerIp: typeof Command.parseNumber;
        serverinstancePermissionsVersion: typeof Command.parseNumber;
        serverinstanceServerqueryFloodBanTime: typeof Command.parseNumber;
        serverinstanceServerqueryFloodCommands: typeof Command.parseNumber;
        serverinstanceServerqueryFloodTime: typeof Command.parseNumber;
        serverinstanceTemplateChanneladminGroup: typeof Command.parseString;
        serverinstanceTemplateChanneldefaultGroup: typeof Command.parseString;
        serverinstanceTemplateServeradminGroup: typeof Command.parseNumber;
        serverinstanceTemplateServerdefaultGroup: typeof Command.parseString;
        msgid: typeof Command.parseString;
        timestamp: typeof Command.parseNumber;
        cluid: typeof Command.parseString;
        subject: typeof Command.parseString;
        message: typeof Command.parseString;
        version: typeof Command.parseString;
        build: typeof Command.parseNumber;
        platform: typeof Command.parseString;
        name: typeof Command.parseString;
        token: typeof Command.parseString;
        tokencustomset: typeof Command.parseRecursive;
        value: typeof Command.parseString;
        banid: typeof Command.parseString;
        id: typeof Command.parseString;
        msg: typeof Command.parseString;
        extraMsg: typeof Command.parseString;
        failedPermid: typeof Command.parseString;
        ident: typeof Command.parseString;
        ip: typeof Command.parseString;
        nickname: typeof Command.parseString;
        uid: typeof Command.parseString;
        desc: typeof Command.parseString;
        pwClear: typeof Command.parseString;
        start: typeof Command.parseNumber;
        end: typeof Command.parseNumber;
        tcid: typeof Command.parseString;
        permname: typeof Command.parseString;
        permdesc: typeof Command.parseString;
        tokenType: typeof Command.parseNumber;
        tokenCustomset: typeof Command.parseRecursive;
        token1: typeof Command.parseString;
        token2: typeof Command.parseString;
        tokenId1: typeof Command.parseString;
        tokenId2: typeof Command.parseString;
        tokenCreated: typeof Command.parseNumber;
        tokenDescription: typeof Command.parseString;
        flagRead: typeof Command.parseBoolean;
        tcldbid: typeof Command.parseString;
        tname: typeof Command.parseString;
        fcldbid: typeof Command.parseString;
        fname: typeof Command.parseString;
        mytsid: typeof Command.parseString;
        lastnickname: typeof Command.parseString;
        created: typeof Command.parseNumber;
        duration: typeof Command.parseNumber;
        invokercldbid: typeof Command.parseString;
        enforcements: typeof Command.parseNumber;
        reason: typeof Command.parseString;
        type: typeof Command.parseNumber;
        iconid: typeof Command.parseString;
        savedb: typeof Command.parseNumber;
        namemode: typeof Command.parseNumber;
        nModifyp: typeof Command.parseNumber;
        nMemberAddp: typeof Command.parseNumber;
        nMemberRemovep: typeof Command.parseNumber;
        sortid: typeof Command.parseString;
        count: typeof Command.parseNumber;
        salt: typeof Command.parseString;
        snapshot: typeof Command.parseString;
        apikey: typeof Command.parseString;
        scope: typeof Command.parseString;
        timeLeft: typeof Command.parseNumber;
        createdAt: typeof Command.parseNumber;
        expiresAt: typeof Command.parseNumber;
    };
}
