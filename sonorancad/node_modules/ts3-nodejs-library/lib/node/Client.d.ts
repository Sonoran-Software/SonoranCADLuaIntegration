/// <reference types="node" />
import { Abstract } from "./Abstract";
import { TeamSpeak } from "../TeamSpeak";
import { ClientEntry } from "../types/ResponseTypes";
import { ClientDBEdit, ClientEdit } from "../types/PropertyTypes";
import { TeamSpeakChannel } from "./Channel";
import { TeamSpeakServerGroup } from "./ServerGroup";
import { Permission } from "../util/Permission";
export declare class TeamSpeakClient extends Abstract<ClientEntry> {
    constructor(parent: TeamSpeak, list: ClientEntry);
    get clid(): string;
    get cid(): string;
    get databaseId(): string;
    get nickname(): string;
    get type(): number;
    get uniqueIdentifier(): string;
    get away(): number;
    get awayMessage(): string;
    get flagTalking(): boolean;
    get inputMuted(): boolean;
    get outputMuted(): boolean;
    get inputHardware(): boolean;
    get outputHardware(): boolean;
    get talkPower(): number;
    get isTalker(): boolean;
    get isPrioritySpeaker(): boolean;
    get isRecording(): boolean;
    get isChannelCommander(): number;
    get servergroups(): string[];
    get channelGroupId(): string;
    get channelGroupInheritedChannelId(): number;
    get version(): string;
    get platform(): string;
    get idleTime(): number;
    get created(): number;
    get lastconnected(): number;
    get country(): string | undefined;
    get estimatedLocation(): string | undefined;
    get connectionClientIp(): string;
    get badges(): string;
    /** evaluates if the client is a query client or a normal client */
    isQuery(): boolean;
    /**
     * Retrieves a displayable Client Link for the TeamSpeak Chat
     */
    getUrl(): string;
    /** returns general info of the client, requires the client to be online */
    getInfo(): Promise<import("../types/ResponseTypes").ClientInfo>;
    /** returns the clients database info */
    getDBInfo(): Promise<import("../types/ResponseTypes").ClientDBInfo>;
    /** returns a list of custom properties for the client */
    customInfo(): Promise<import("../types/ResponseTypes").CustomInfo>;
    /**
     * removes a custom property from the client
     * @param ident the key which should be deleted
     */
    customDelete(ident: string): Promise<[]>;
    /**
     * creates or updates a custom property for the client
     * ident and value can be any value, and are the key value pair of the custom property
     * @param ident the key which should be set
     * @param value the value which should be set
     */
    customSet(ident: string, value: string): Promise<[]>;
    /**
     * kicks the client from the server
     * @param msg the message the client should receive when getting kicked
     */
    kickFromServer(msg: string): Promise<[]>;
    /**
     * kicks the client from their currently joined channel
     * @param msg the message the client should receive when getting kicked (max 40 Chars)
     */
    kickFromChannel(msg: string): Promise<[]>;
    /**
     * bans the chosen client with its uid
     * @param banreason ban reason
     * @param time bantime in seconds, if left empty it will result in a permaban
     */
    ban(banreason: string, time?: number): Promise<import("../types/ResponseTypes").BanAdd>;
    /**
     * moves the client to a different channel
     * @param cid channel id in which the client should get moved
     * @param cpw the channel password
     */
    move(cid: string | TeamSpeakChannel, cpw?: string): Promise<[]>;
    /**
     * adds the client to one or more groups
     * @param sgid one or more servergroup ids which the client should be added to
     */
    addGroups(sgid: string | string[] | TeamSpeakServerGroup | TeamSpeakServerGroup[]): Promise<[]>;
    /**
     * Removes the client from one or more groups
     * @param sgid one or more servergroup ids which the client should be added to
     */
    delGroups(sgid: string | string[] | TeamSpeakServerGroup | TeamSpeakServerGroup[]): Promise<[]>;
    /**
     * edits the client
     * @param properties the properties to change
     */
    edit(properties: ClientEdit): Promise<[]>;
    /**
     * Changes a clients settings using given properties.
     * @param properties the properties which should be modified
     */
    dbEdit(properties: ClientDBEdit): Promise<[]>;
    /**
     * pokes the client with a certain message
     * @param msg the message the client should receive
     */
    poke(msg: string): Promise<[]>;
    /**
     * sends a textmessage to the client
     * @param msg the message the client should receive
     */
    message(msg: string): any;
    /**
     * returns a list of permissions defined for the client
     * @param permsid if the permsid option is set to true the output will contain the permission names
     */
    permList(permsid?: boolean): Promise<Permission<{
        cldbid: string;
    }>[]>;
    /**
     * Adds a set of specified permissions to a client.
     * Multiple permissions can be added by providing the three parameters of each permission.
     * A permission can be specified by permid or permsid.
     * @param perm the permission object to set
     */
    addPerm(perm: Permission.PermType): Promise<[]>;
    /**
     * Adds a set of specified permissions to a client.
     * Multiple permissions can be added by providing the three parameters of each permission.
     * A permission can be specified by permid or permsid.
     */
    createPerm(): Permission<any>;
    /**
     * Removes a set of specified permissions from a client.
     * Multiple permissions can be removed at once.
     * A permission can be specified by permid or permsid
     * @param perm the permid or permsid
     */
    delPerm(perm: string | number): Promise<[]>;
    /** returns a Buffer with the avatar of the user */
    getAvatar(): Promise<Buffer>;
    /** returns a Buffer with the icon of the client */
    getIcon(): Promise<Buffer>;
    /** returns the avatar name of the client */
    getAvatarName(): Promise<string>;
    /** gets the icon name of the client */
    getIconId(): Promise<number>;
    /** retrieves the client id from a string or teamspeak client */
    static getId<T extends TeamSpeakClient.ClientType>(client?: T): T extends undefined ? undefined : string;
    /** retrieves the client dbid from a string or teamspeak client */
    static getDbid<T extends TeamSpeakClient.ClientType>(client?: T): T extends undefined ? undefined : string;
    /** retrieves the client dbid from a string or teamspeak client */
    static getUid<T extends TeamSpeakClient.ClientType>(client?: T): T extends undefined ? undefined : string;
    /** retrieves the clients from an array */
    static getMultipleIds(client: TeamSpeakClient.MultiClientType): string[];
    /** retrieves the clients from an array */
    static getMultipleDbids(client: TeamSpeakClient.MultiClientType): string[];
    /** retrieves the clients from an array */
    static getMultipleUids(client: TeamSpeakClient.MultiClientType): string[];
}
export declare namespace TeamSpeakClient {
    type ClientType = string | TeamSpeakClient;
    type MultiClientType = string[] | TeamSpeakClient[] | ClientType;
}
