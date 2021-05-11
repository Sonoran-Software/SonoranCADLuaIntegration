"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.TeamSpeakServerGroup = void 0;
const Abstract_1 = require("./Abstract");
class TeamSpeakServerGroup extends Abstract_1.Abstract {
    constructor(parent, list) {
        super(parent, list, "servergroup");
    }
    get sgid() {
        return super.getPropertyByName("sgid");
    }
    get name() {
        return super.getPropertyByName("name");
    }
    get type() {
        return super.getPropertyByName("type");
    }
    get iconid() {
        return super.getPropertyByName("iconid");
    }
    get savedb() {
        return super.getPropertyByName("savedb");
    }
    get sortid() {
        return super.getPropertyByName("sortid");
    }
    get namemode() {
        return super.getPropertyByName("namemode");
    }
    get nModifyp() {
        return super.getPropertyByName("nModifyp");
    }
    get nMemberAddp() {
        return super.getPropertyByName("nMemberAddp");
    }
    get nMemberRemovep() {
        return super.getPropertyByName("nMemberRemovep");
    }
    /**
     * Deletes the server group.
     * If force is set to 1, the server group will be deleted even if there are clients within.
     * @param force if set to 1 the servergroup will be deleted even when clients are in it
     */
    del(force) {
        return super.getParent().serverGroupDel(this, force);
    }
    /**
     * Creates a copy of the server group specified with ssgid. If tsgid is set to 0, the server will create a new group.
     * To overwrite an existing group, simply set tsgid to the ID of a designated target group.
     * If a target group is set, the name parameter will be ignored.
     * @param tsgid the target group, 0 to create a new group
     * @param type type of the group (0 = Query Group | 1 = Normal Group)
     * @param name name of the group
     */
    copy(targetGroup, type, name) {
        return super.getParent().serverGroupCopy(this, targetGroup, type, name);
    }
    /**
     * changes the name of the server group
     * @param name new name of the group
     */
    rename(name) {
        return super.getParent().serverGroupRename(this, name);
    }
    /**
     * returns a list of permissions assigned to the server group specified with sgid
     * @param permsid if the permsid option is set to true the output will contain the permission names
     */
    permList(permsid) {
        return super.getParent().serverGroupPermList(this, permsid);
    }
    /**
     * Adds a specified permissions to the server group.
     * A permission can be specified by permid or permsid.
     * @param perm the permission object to set
     */
    addPerm(perm) {
        return super.getParent().serverGroupAddPerm(this, perm);
    }
    /**
     * Adds a specified permissions to the server group.
     * A permission can be specified by permid or permsid.
     */
    createPerm() {
        return super.getParent().serverGroupAddPerm(this, undefined);
    }
    /**
     * rmoves a set of specified permissions from the server group.
     * A permission can be specified by permid or permsid.
     * @param perm the permid or permsid
     */
    delPerm(perm) {
        return super.getParent().serverGroupDelPerm(this, perm);
    }
    /**
     * Adds a client to the server group. Please note that a client cannot be added to default groups or template groups.
     * @param client the client database id which should be added to the Group
     */
    addClient(client) {
        return super.getParent().serverGroupAddClient(client, this);
    }
    /**
     * removes a client specified with cldbid from the servergroup
     * @param client the client database id which should be removed from the group
     */
    delClient(client) {
        return super.getParent().serverGroupDelClient(client, this);
    }
    /** returns the ids of all clients currently residing in the server group */
    clientList() {
        return super.getParent().serverGroupClientList(this);
    }
    /** returns a buffer with the icon of the servergroup */
    getIcon() {
        return this.getIconId().then(id => super.getParent().downloadIcon(id));
    }
    /** gets the icon id of the servergroup */
    getIconId() {
        return super.getParent().getIconId(this.permList(true));
    }
    static getId(group) {
        return group instanceof TeamSpeakServerGroup ? group.sgid : group;
    }
    /** retrieves the clients from an array */
    static getMultipleIds(groups) {
        const list = Array.isArray(groups) ? groups : [groups];
        return list.map(c => TeamSpeakServerGroup.getId(c));
    }
}
exports.TeamSpeakServerGroup = TeamSpeakServerGroup;
//# sourceMappingURL=ServerGroup.js.map