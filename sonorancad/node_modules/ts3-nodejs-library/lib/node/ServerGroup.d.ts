/// <reference types="node" />
import { Abstract } from "./Abstract";
import { TeamSpeak } from "../TeamSpeak";
import { ServerGroupEntry } from "../types/ResponseTypes";
import { TeamSpeakClient } from "./Client";
import { Permission } from "../util/Permission";
export declare class TeamSpeakServerGroup extends Abstract<ServerGroupEntry> {
    constructor(parent: TeamSpeak, list: ServerGroupEntry);
    get sgid(): string;
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
     * Deletes the server group.
     * If force is set to 1, the server group will be deleted even if there are clients within.
     * @param force if set to 1 the servergroup will be deleted even when clients are in it
     */
    del(force?: boolean): Promise<[]>;
    /**
     * Creates a copy of the server group specified with ssgid. If tsgid is set to 0, the server will create a new group.
     * To overwrite an existing group, simply set tsgid to the ID of a designated target group.
     * If a target group is set, the name parameter will be ignored.
     * @param tsgid the target group, 0 to create a new group
     * @param type type of the group (0 = Query Group | 1 = Normal Group)
     * @param name name of the group
     */
    copy(targetGroup: string | TeamSpeakServerGroup, type: number, name: string): Promise<import("../types/ResponseTypes").ServerGroupCopy>;
    /**
     * changes the name of the server group
     * @param name new name of the group
     */
    rename(name: string): Promise<[]>;
    /**
     * returns a list of permissions assigned to the server group specified with sgid
     * @param permsid if the permsid option is set to true the output will contain the permission names
     */
    permList(permsid: boolean): Promise<Permission<{
        sgid: string;
    }>[]>;
    /**
     * Adds a specified permissions to the server group.
     * A permission can be specified by permid or permsid.
     * @param perm the permission object to set
     */
    addPerm(perm: Permission.PermType): Promise<[]>;
    /**
     * Adds a specified permissions to the server group.
     * A permission can be specified by permid or permsid.
     */
    createPerm(): Permission<any>;
    /**
     * rmoves a set of specified permissions from the server group.
     * A permission can be specified by permid or permsid.
     * @param perm the permid or permsid
     */
    delPerm(perm: string | number): Promise<[]>;
    /**
     * Adds a client to the server group. Please note that a client cannot be added to default groups or template groups.
     * @param client the client database id which should be added to the Group
     */
    addClient(client: TeamSpeakClient.ClientType): Promise<[]>;
    /**
     * removes a client specified with cldbid from the servergroup
     * @param client the client database id which should be removed from the group
     */
    delClient(client: TeamSpeakClient.ClientType): Promise<[]>;
    /** returns the ids of all clients currently residing in the server group */
    clientList(): Promise<import("../types/ResponseTypes").ServerGroupClientEntry[]>;
    /** returns a buffer with the icon of the servergroup */
    getIcon(): Promise<Buffer>;
    /** gets the icon id of the servergroup */
    getIconId(): Promise<number>;
    /** retrieves the client id from a string or teamspeak client */
    static getId<T extends TeamSpeakServerGroup.GroupType>(group?: T): T extends undefined ? undefined : string;
    /** retrieves the clients from an array */
    static getMultipleIds(groups: TeamSpeakServerGroup.MultiGroupType): string[];
}
export declare namespace TeamSpeakServerGroup {
    type GroupType = string | TeamSpeakServerGroup;
    type MultiGroupType = string[] | TeamSpeakServerGroup[] | GroupType;
}
