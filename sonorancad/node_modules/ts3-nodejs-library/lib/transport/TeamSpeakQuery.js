"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.TeamSpeakQuery = void 0;
const events_1 = require("events");
const Command_1 = require("./Command");
const raw_1 = require("./protocols/raw");
const ssh_1 = require("./protocols/ssh");
const TeamSpeak_1 = require("../TeamSpeak");
class TeamSpeakQuery extends events_1.EventEmitter {
    constructor(config) {
        super();
        this.queue = [];
        this.ignoreLines = TeamSpeakQuery.IGNORE_LINES_INITIAL;
        this.lastEvent = "";
        this.lastcmd = Date.now();
        this.connected = false;
        this.pauseQueue = true;
        this.doubleEvents = [
            "notifyclientleftview",
            "notifyclientmoved",
            "notifycliententerview"
        ];
        this.config = config;
    }
    /**
     * start connecting to the teamspeak server
     */
    connect() {
        if (this.socket) {
            if (this.connected) {
                throw new Error("already connected");
            }
            else {
                /**
                 * socket has already been connected and there was an active item
                 * push it back into the queue for possible priorized elements
                 */
                if (this.active) {
                    this.queue.unshift(this.active);
                    this.active = undefined;
                }
                this.socket.removeAllListeners();
                this.ignoreLines = TeamSpeakQuery.IGNORE_LINES_INITIAL;
            }
        }
        this.socket = TeamSpeakQuery.getSocket(this.config);
        this.socket.on("debug", data => this.emit("debug", data));
        this.socket.on("connect", this.handleConnect.bind(this));
        this.socket.on("line", this.handleLine.bind(this));
        this.socket.on("error", this.handleError.bind(this));
    }
    /** returns a constructed Socket */
    static getSocket(config) {
        if (config.protocol === TeamSpeak_1.TeamSpeak.QueryProtocol.RAW) {
            return new raw_1.ProtocolRAW(config);
        }
        else if (config.protocol === TeamSpeak_1.TeamSpeak.QueryProtocol.SSH) {
            return new ssh_1.ProtocolSSH(config);
        }
        else {
            throw new Error("Invalid Protocol given! Expected (\"raw\" or \"ssh\")");
        }
    }
    /** sends a command to the TeamSpeak Server */
    execute(command, ...args) {
        return this.handleCommand(command, args);
    }
    /** sends a priorized command to the TeamSpeak Server */
    executePrio(command, ...args) {
        return this.handleCommand(command, args, true);
    }
    /**
     * @param command command to send
     * @param args arguments which gets parsed
     * @param prio wether this command should be handled as priority and be queued before others
     */
    handleCommand(command, args, priority = false) {
        return new Promise((fulfill, reject) => {
            const cmd = new Command_1.Command().setCommand(command);
            Object.values(args).forEach(v => {
                if (Array.isArray(v)) {
                    if (v.some(value => typeof value === "object" && value !== null)) {
                        return cmd.setMultiOptions(v.filter(n => n !== null));
                    }
                    else {
                        return cmd.setFlags(v);
                    }
                }
                else if (typeof v === "function") {
                    return cmd.setParser(v);
                }
                else {
                    return cmd.setOptions(v);
                }
            });
            this.queueWorker({ cmd, fulfill, reject, priority });
        });
    }
    /** forcefully closes the socket connection */
    forceQuit() {
        this.pause(true);
        return this.socket.close();
    }
    pause(pause) {
        this.pauseQueue = pause;
        if (!this.pauseQueue)
            this.queueWorker();
        return this;
    }
    /** gets called when the underlying transport layer connects to a server */
    handleConnect() {
        this.connected = true;
        this.socket.on("close", this.handleClose.bind(this));
        this.emit("connect");
    }
    /** handles a single line response from the teamspeak server */
    handleLine(line) {
        line = line.trim();
        this.emit("debug", { type: "receive", data: line });
        if (this.ignoreLines > 0 && !line.startsWith("error")) {
            this.ignoreLines -= 1;
            if (this.ignoreLines > 0)
                return;
            this.emit("ready");
            this.queueWorker();
        }
        else if (line.startsWith("error")) {
            this.handleQueryError(line);
        }
        else if (line.startsWith("notify")) {
            this.handleQueryEvent(line);
        }
        else if (this.active && this.active.cmd) {
            this.active.cmd.setResponse(line);
        }
    }
    /** handles the error line which finnishes a command */
    handleQueryError(line) {
        if (!this.active)
            return;
        this.active.cmd.setError(line);
        if (this.active.cmd.hasError()) {
            const error = this.active.cmd.getError();
            if (error.id === "524") {
                return this.handleFloodingError(this.active);
            }
            else {
                this.active.reject(this.active.cmd.getError());
            }
        }
        else {
            this.active.fulfill(this.active.cmd.getResponse());
        }
        this.active = undefined;
        this.queueWorker();
    }
    /** handles a flooding response from the teamspeak query */
    handleFloodingError(active) {
        this.emit("flooding", active.cmd.getError());
        const match = active.cmd.getError().message.match(/(\d*) second/i);
        const waitTimeout = match ? parseInt(match[1], 10) : 1;
        clearTimeout(this.floodTimeout);
        this.floodTimeout = setTimeout((cmd => (() => {
            cmd.reset();
            this.send(cmd.build());
        }))(active.cmd), waitTimeout * 1000 + 100);
        return;
    }
    /**
     * Handles an event which has been received from the TeamSpeak Server
     * @param line event response line from the teamspeak server
     */
    handleQueryEvent(line) {
        if (this.doubleEvents.some(s => line.includes(s)) && line === this.lastEvent)
            return;
        /**
         * Query Event
         * Gets fired when the Query receives an Event
         * @event TeamSpeakQuery#<TeamSpeakEvent>
         * @memberof  TeamSpeakQuery
         * @type {object}
         */
        this.emit(line.substr(6, line.indexOf(" ") - 6), Command_1.Command.parse({ raw: line.substr(line.indexOf(" ") + 1) })[0]);
    }
    /**
     * Emits an Error which the given arguments
     * @param {...any} args arguments which gets passed to the error event
     */
    handleError(error) {
        /**
         * Query Event
         * Gets fired when the Socket had an Error
         * @event TeamSpeakQuery#error
         * @memberof TeamSpeakQuery
         */
        this.emit("error", error);
    }
    /** handles socket closing */
    handleClose() {
        this.connected = false;
        this.pause(true);
        clearTimeout(this.floodTimeout);
        clearTimeout(this.keepAliveTimeout);
        const cmd = new Command_1.Command().setError(this.socket.chunk || "");
        this.emit("close", cmd.getError());
    }
    /** handles the timer for the keepalive request */
    keepAlive() {
        if (!this.config.keepAlive)
            return;
        clearTimeout(this.keepAliveTimeout);
        this.keepAliveTimeout = setTimeout(() => this.sendKeepAlive(), this.config.keepAliveTimeout * 1000 - (Date.now() - this.lastcmd));
    }
    /** dispatches the keepalive */
    sendKeepAlive() {
        this.emit("debug", { type: "keepalive" });
        this.lastcmd = Date.now();
        this.socket.sendKeepAlive();
        this.keepAlive();
    }
    /** executes the next command */
    queueWorker(cmd) {
        if (cmd)
            this.queue.push(cmd);
        if (!this.connected || this.active || this.pauseQueue)
            return;
        this.active = this.getNextQueueItem();
        if (!this.active)
            return;
        this.send(this.active.cmd.build());
    }
    /**
     * retrieves the next available queue item
     * respects priorized queue
     */
    getNextQueueItem() {
        const item = this.queue.find(i => i.priority);
        if (item) {
            this.queue = this.queue.filter(i => i !== item);
            return item;
        }
        return this.queue.shift();
    }
    /** sends data to the socket */
    send(data) {
        this.lastcmd = Date.now();
        this.emit("debug", { type: "send", data });
        this.socket.send(data);
        this.keepAlive();
    }
    isConnected() {
        return this.connected;
    }
}
exports.TeamSpeakQuery = TeamSpeakQuery;
TeamSpeakQuery.IGNORE_LINES_INITIAL = 2;
//# sourceMappingURL=TeamSpeakQuery.js.map