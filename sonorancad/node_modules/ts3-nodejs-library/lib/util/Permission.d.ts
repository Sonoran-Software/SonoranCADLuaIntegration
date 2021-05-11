import { TeamSpeak } from "../TeamSpeak";
export declare class Permission<T extends {} = any> {
    private teamspeak;
    private _perm?;
    private _value;
    private _skip;
    private _negate;
    private withSkipNegate;
    private cmdUpdate;
    private cmdRemove;
    private context;
    constructor(config: Permission.IConfig<T>);
    /** retrieves the current permission */
    getPerm(): string | number | undefined;
    /** retrieves the permission value */
    getValue(): number;
    /** retrieves wether skip has been set */
    getSkip(): boolean;
    /** retrieves wether negate has been set */
    getNegate(): boolean;
    /** sets/gets the permid or permsid */
    perm(perm: string | number): Permission<T>;
    /** sets/gets the value for the permission */
    value(value: number): Permission<T>;
    /** sets/gets the skip value */
    skip(skip: boolean): Permission<T>;
    /** sets/gets the negate value */
    negate(negate: boolean): Permission<T>;
    /** retrieves the permission object */
    get(): Permission.PermId | Permission.PermSid;
    /** retrieves skip and negate flags */
    private getFlags;
    /** retrieves a raw object with permid */
    private getAsPermId;
    /** retrieves a raw object with permsid */
    private getAsPermSid;
    /** retrieves the correct permission name */
    private getPermName;
    /** updates or adds the permission to the teamspeak server */
    update(): Promise<[]>;
    /** removes the specified permission */
    remove(): Promise<[]>;
    static getDefaults(perm: Partial<Permission.PermType>): Partial<Permission.PermType>;
}
export declare namespace Permission {
    interface IConfig<T> {
        teamspeak: TeamSpeak;
        remove: string;
        update: string;
        context: T;
        allowSkipNegate?: boolean;
    }
    interface BasePermission {
        permvalue: number;
        skip?: boolean;
        negate?: boolean;
    }
    interface PermSid extends BasePermission {
        permsid: string;
    }
    interface PermId extends BasePermission {
        permid: number;
    }
    type PermType = {
        permname: string | number;
        permvalue: number;
        permskip?: boolean;
        permnegated?: boolean;
    };
}
