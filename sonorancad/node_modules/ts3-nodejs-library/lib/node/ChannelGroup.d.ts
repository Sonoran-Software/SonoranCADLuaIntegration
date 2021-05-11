/// <reference types="node" />
import { Abstract } from "./Abstract";
import { TeamSpeak } from "../TeamSpeak";
import { ChannelGroupEntry } from "../types/ResponseTypes";
import { TeamSpeakChannel } from "./Channel";
import { TeamSpeakClient } from "./Client";
import { Permission } from "../util/Permission";
export declare class TeamSpeakChannelGroup extends Abstract<ChannelGroupEntry> {
    constructor(parent: TeamSpeak, list: ChannelGroupEntry);
    get cgid(): string;
    get name(): string;
    get type(): number;
    get iconid(): string;
    get savedb(): number;
    get sortid(): number;
    get namemode(): number;
    get nModifyp(): number;
    get nMemberAddp(): number;
    get nMemberRemovep(): number;
    /**
     * Deletes the channel group. If force is set to 1, the channel group will be deleted even if there are clients within.
     * @param force if set to 1 the channelgroup will be deleted even when clients are in it
     */
    del(force?: boolean): Promise<[]>;
    /**
     * Creates a copy of the channel group. If tcgid is set to 0, the server will create a new group.
     * To overwrite an existing group, simply set tcgid to the ID of a designated target group.
     * If a target group is set, the name parameter will be ignored.
     * @param tcgid the target group, 0 to create a new group
     * @param type the type of the group (0 = Template Group | 1 = Normal Group)
     * @param name name of the group
     */
    copy(tcgid: string | TeamSpeakChannelGroup, type: number, name: string): Promise<import("../types/ResponseTypes").ChannelGroupCopy>;
    /**
     * changes the name of the channelgroup
     * @param name new name of the group
     */
    rename(name: string): Promise<[]>;
    /**
     * returns a list of permissions assigned to the channel group specified with cgid.
     * @param permsid if the permsid option is set to true the output will contain the permission names
     */
    permList(permsid?: boolean): Promise<Permission<{
        cgid: string;
    }>[]>;
    /**
     * Adds a specified permissions to the channel group.
     * A permission can be specified by permid or permsid.
     * @param perm the permission object
     */
    addPerm(perm: Permission.PermType): Promise<[]>;
    /**
     * Adds a specified permissions to the channel group.
     * A permission can be specified by permid or permsid.
     */
    createPerm(): Permission<any>;
    /**
     * Removes a set of specified permissions from the channel group.
     * A permission can be specified by permid or permsid.
     * @param perm the permid or permsid
     */
    delPerm(perm: string | number): Promise<[]>;
    /**
     * sets the channel group of a client
     * @param channel the channel in which the client should be assigned the Group
     * @param client the client database id which should be added to the Group
     */
    setClient(channel: string | TeamSpeakChannel, client: string | TeamSpeakClient): Promise<[]>;
    /**
     * returns the ids of all clients currently residing in the channelgroup
     * @param channel the channel id
     */
    clientList(channel: string | TeamSpeakChannel): Promise<import("../types/ResponseTypes").ChannelGroupClientList>;
    /** returns a buffer with the icon of the channelgroup */
    getIcon(): Promise<Buffer>;
    /** gets the icon name of the channelgroup */
    getIconId(): Promise<number>;
    /** retrieves the client id from a string or teamspeak client */
    static getId<T extends TeamSpeakChannelGroup.GroupType>(channel?: T): T extends undefined ? undefined : string;
    /** retrieves the clients from an array */
    static getMultipleIds(client: TeamSpeakChannelGroup.MultiGroupType): string[];
}
export declare namespace TeamSpeakChannelGroup {
    type GroupType = string | TeamSpeakChannelGroup;
    type MultiGroupType = string[] | TeamSpeakChannelGroup[] | GroupType;
}
