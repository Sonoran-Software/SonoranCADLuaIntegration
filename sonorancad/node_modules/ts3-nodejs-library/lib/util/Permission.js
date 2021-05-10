"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Permission = void 0;
class Permission {
    constructor(config) {
        this._value = 0;
        this._skip = false;
        this._negate = false;
        this.cmdUpdate = config.update;
        this.cmdRemove = config.remove;
        this.teamspeak = config.teamspeak;
        this.withSkipNegate = config.allowSkipNegate === false ? false : true;
        this.context = config.context;
    }
    /** retrieves the current permission */
    getPerm() {
        return this._perm;
    }
    /** retrieves the permission value */
    getValue() {
        return this._value;
    }
    /** retrieves wether skip has been set */
    getSkip() {
        return this._skip || false;
    }
    /** retrieves wether negate has been set */
    getNegate() {
        return this._negate || false;
    }
    /** sets/gets the permid or permsid */
    perm(perm) {
        this._perm = perm;
        return this;
    }
    /** sets/gets the value for the permission */
    value(value) {
        this._value = value;
        return this;
    }
    /** sets/gets the skip value */
    skip(skip) {
        this._skip = skip;
        return this;
    }
    /** sets/gets the negate value */
    negate(negate) {
        this._negate = negate;
        return this;
    }
    /** retrieves the permission object */
    get() {
        if (!this._perm)
            throw new Error("Permission#perm has not been called yet");
        if (typeof this._perm === "string")
            return this.getAsPermSid();
        return this.getAsPermId();
    }
    /** retrieves skip and negate flags */
    getFlags() {
        if (!this.withSkipNegate)
            return {};
        return { permskip: this._skip, permnegated: this._negate };
    }
    /** retrieves a raw object with permid */
    getAsPermId() {
        if (typeof this._perm !== "number")
            throw new Error(`permission needs to be a number but got '${this._perm}'`);
        return {
            permid: this._perm,
            permvalue: this._value,
            ...this.getFlags()
        };
    }
    /** retrieves a raw object with permsid */
    getAsPermSid() {
        if (typeof this._perm !== "string")
            throw new Error(`permission needs to be a string but got '${this._perm}'`);
        return {
            permsid: this._perm,
            permvalue: this._value,
            ...this.getFlags()
        };
    }
    /** retrieves the correct permission name */
    getPermName() {
        return typeof this._perm === "string" ? "permsid" : "permid";
    }
    /** updates or adds the permission to the teamspeak server */
    update() {
        return this.teamspeak.execute(this.cmdUpdate, {
            ...this.context,
            ...this.get()
        });
    }
    /** removes the specified permission */
    remove() {
        return this.teamspeak.execute(this.cmdRemove, {
            ...this.context,
            [this.getPermName()]: this._perm
        });
    }
    static getDefaults(perm) {
        return {
            permskip: false,
            permnegated: false,
            ...perm
        };
    }
}
exports.Permission = Permission;
//# sourceMappingURL=Permission.js.map