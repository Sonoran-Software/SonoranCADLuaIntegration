"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.TeamSpeakChannel = void 0;
const Abstract_1 = require("./Abstract");
class TeamSpeakChannel extends Abstract_1.Abstract {
    constructor(parent, list) {
        super(parent, list, "channel");
    }
    get cid() {
        return super.getPropertyByName("cid");
    }
    get pid() {
        return super.getPropertyByName("pid");
    }
    get order() {
        return super.getPropertyByName("channelOrder");
    }
    get name() {
        return super.getPropertyByName("channelName");
    }
    get topic() {
        return super.getPropertyByName("channelTopic");
    }
    get flagDefault() {
        return super.getPropertyByName("channelFlagDefault");
    }
    get flagPassword() {
        return super.getPropertyByName("channelFlagPassword");
    }
    get flagPermanent() {
        return super.getPropertyByName("channelFlagPermanent");
    }
    get flagSemiPermanent() {
        return super.getPropertyByName("channelFlagSemiPermanent");
    }
    get codec() {
        return super.getPropertyByName("channelCodec");
    }
    get codecQuality() {
        return super.getPropertyByName("channelCodecQuality");
    }
    get neededTalkPower() {
        return super.getPropertyByName("channelNeededTalkPower");
    }
    get iconId() {
        return super.getPropertyByName("channelIconId");
    }
    get secondsEmpty() {
        return super.getPropertyByName("secondsEmpty");
    }
    get totalClientsFamily() {
        return super.getPropertyByName("totalClientsFamily");
    }
    get maxclients() {
        return super.getPropertyByName("channelMaxclients");
    }
    get maxfamilyclients() {
        return super.getPropertyByName("channelMaxfamilyclients");
    }
    get totalClients() {
        return super.getPropertyByName("totalClients");
    }
    get neededSubscribePower() {
        return super.getPropertyByName("channelNeededSubscribePower");
    }
    get bannerGfxUrl() {
        return super.getPropertyByName("channelBannerGfxUrl");
    }
    get bannerMode() {
        return super.getPropertyByName("channelBannerMode");
    }
    /** returns detailed configuration information about a channel including ID, topic, description, etc */
    getInfo() {
        return super.getParent().channelInfo(this);
    }
    /**
     * Moves a channel to a new parent channel with the ID cpid.
     * If order is specified, the channel will be sorted right under the channel with the specified ID.
     * If order is set to 0, the channel will be sorted right below the new parent.
     * @param parent channel parent id
     * @param order channel sort order
     */
    move(parent, order = 0) {
        return super.getParent().channelMove(this, parent, order);
    }
    /**
     * Deletes an existing channel by ID.
     * If force is set to 1, the channel will be deleted even if there are clients within.
     * The clients will be kicked to the default channel with an appropriate reason message.
     * @param {number} force if set to 1 the channel will be deleted even when clients are in it
     */
    del(force = false) {
        return super.getParent().channelDelete(this, force);
    }
    /**
     * Changes a channels configuration using given properties. Note that this command accepts multiple properties which means that you're able to change all settings of the channel specified with cid at once.
     * @param properties the properties of the channel which should get changed
     */
    edit(properties) {
        return super.getParent().channelEdit(this, properties);
    }
    /**
     * Displays a list of permissions defined for a channel.
     * @param permsid whether the permsid should be displayed aswell
     */
    permList(permsid = false) {
        return super.getParent().channelPermList(this, permsid);
    }
    /**
     * Adds a set of specified permissions to a channel.
     * Multiple permissions can be added by providing the two parameters of each permission.
     * A permission can be specified by permid or permsid.
     * @param perm permission object to set
     */
    setPerm(perm) {
        return super.getParent().channelSetPerm(this, perm);
    }
    /**
     * Adds a permission to a channel
     * Multiple permissions can be added by providing the two parameters of each permission.
     * A permission can be specified by permid or permsid.
     * @param perm permission object to set
     */
    createPerm() {
        return super.getParent().channelSetPerm(this, undefined);
    }
    /**
     * Removes a set of specified permissions from a channel.
     * Multiple permissions can be removed at once.
     * A permission can be specified by permid or permsid.
     * @param perm the permid or permsid
     */
    delPerm(perm) {
        return super.getParent().channelDelPerm(this, perm);
    }
    /**
     * Gets a List of Clients in the current Channel
     * @param filter the filter object
     */
    getClients(filter = {}) {
        filter.cid = this.cid;
        return super.getParent().clientList(filter);
    }
    /** returns a buffer with the icon of the channel */
    getIcon() {
        return this.getIconId().then(id => super.getParent().downloadIcon(id));
    }
    /** returns the icon name of the channel */
    getIconId() {
        return super.getParent().getIconId(this.permList(true));
    }
    static getId(channel) {
        return channel instanceof TeamSpeakChannel ? channel.cid : channel;
    }
    /** retrieves the clients from an array */
    static getMultipleIds(channels) {
        const list = Array.isArray(channels) ? channels : [channels];
        return list.map(c => TeamSpeakChannel.getId(c));
    }
}
exports.TeamSpeakChannel = TeamSpeakChannel;
//# sourceMappingURL=Channel.js.map