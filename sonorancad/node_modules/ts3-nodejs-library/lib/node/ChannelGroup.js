"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.TeamSpeakChannelGroup = void 0;
const Abstract_1 = require("./Abstract");
class TeamSpeakChannelGroup extends Abstract_1.Abstract {
    constructor(parent, list) {
        super(parent, list, "channelgroup");
    }
    get cgid() {
        return super.getPropertyByName("cgid");
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
     * Deletes the channel group. If force is set to 1, the channel group will be deleted even if there are clients within.
     * @param force if set to 1 the channelgroup will be deleted even when clients are in it
     */
    del(force) {
        return super.getParent().deleteChannelGroup(this, force);
    }
    /**
     * Creates a copy of the channel group. If tcgid is set to 0, the server will create a new group.
     * To overwrite an existing group, simply set tcgid to the ID of a designated target group.
     * If a target group is set, the name parameter will be ignored.
     * @param tcgid the target group, 0 to create a new group
     * @param type the type of the group (0 = Template Group | 1 = Normal Group)
     * @param name name of the group
     */
    copy(tcgid, type, name) {
        return super.getParent().channelGroupCopy(this, tcgid, type, name);
    }
    /**
     * changes the name of the channelgroup
     * @param name new name of the group
     */
    rename(name) {
        return super.getParent().channelGroupRename(this, name);
    }
    /**
     * returns a list of permissions assigned to the channel group specified with cgid.
     * @param permsid if the permsid option is set to true the output will contain the permission names
     */
    permList(permsid = false) {
        return super.getParent().channelGroupPermList(this, permsid);
    }
    /**
     * Adds a specified permissions to the channel group.
     * A permission can be specified by permid or permsid.
     * @param perm the permission object
     */
    addPerm(perm) {
        return super.getParent().channelGroupAddPerm(this, perm);
    }
    /**
     * Adds a specified permissions to the channel group.
     * A permission can be specified by permid or permsid.
     */
    createPerm() {
        return super.getParent().channelGroupAddPerm(this);
    }
    /**
     * Removes a set of specified permissions from the channel group.
     * A permission can be specified by permid or permsid.
     * @param perm the permid or permsid
     */
    delPerm(perm) {
        return super.getParent().channelGroupDelPerm(this, perm);
    }
    /**
     * sets the channel group of a client
     * @param channel the channel in which the client should be assigned the Group
     * @param client the client database id which should be added to the Group
     */
    setClient(channel, client) {
        return super.getParent().setClientChannelGroup(this, channel, client);
    }
    /**
     * returns the ids of all clients currently residing in the channelgroup
     * @param channel the channel id
     */
    clientList(channel) {
        return super.getParent().channelGroupClientList(this, channel);
    }
    /** returns a buffer with the icon of the channelgroup */
    getIcon() {
        return this.getIconId().then(name => super.getParent().downloadIcon(name));
    }
    /** gets the icon name of the channelgroup */
    getIconId() {
        return super.getParent().getIconId(this.permList(true));
    }
    static getId(channel) {
        return channel instanceof TeamSpeakChannelGroup ? channel.cgid : channel;
    }
    /** retrieves the clients from an array */
    static getMultipleIds(client) {
        const list = Array.isArray(client) ? client : [client];
        return list.map(c => TeamSpeakChannelGroup.getId(c));
    }
}
exports.TeamSpeakChannelGroup = TeamSpeakChannelGroup;
//# sourceMappingURL=ChannelGroup.js.map