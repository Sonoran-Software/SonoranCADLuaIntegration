"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ProtocolRAW = void 0;
const net_1 = require("net");
const events_1 = require("events");
class ProtocolRAW extends events_1.EventEmitter {
    constructor(config) {
        super();
        this.chunk = "";
        this.socket = net_1.connect({
            port: config.queryport,
            host: config.host,
            localAddress: config.localAddress
        });
        this.socket.setEncoding("utf8");
        this.socket.setTimeout(config.readyTimeout);
        this.socket.on("timeout", this.handleTimeout.bind(this));
        this.socket.on("connect", this.handleConnect.bind(this));
        this.socket.on("data", this.handleData.bind(this));
        this.socket.on("error", this.handleError.bind(this));
        this.socket.on("close", this.handleClose.bind(this));
    }
    /**
     * Called after the socket was not able to connect within the given timeframe
     */
    handleTimeout() {
        this.socket.destroy();
        this.emit("error", Error("Socket Timeout reached"));
    }
    /**
     * Called after the Socket has been established
     */
    handleConnect() {
        this.socket.setTimeout(0);
        this.emit("connect");
    }
    /**
     * called when the Socket emits an error
     */
    handleError(err) {
        this.emit("error", err);
    }
    /**
     * called when the connection with the Socket gets closed
     */
    handleClose() {
        this.emit("close", String(this.chunk));
    }
    /**
     * called when the Socket receives data
     * Splits the data with every newline
     */
    handleData(chunk) {
        this.chunk += chunk;
        const lines = this.chunk.split("\n");
        this.chunk = lines.pop() || "";
        lines.forEach(line => this.emit("line", line));
    }
    send(str) {
        this.socket.write(`${str}\n`);
    }
    sendKeepAlive() {
        this.socket.write(" \n");
    }
    close() {
        return this.socket.destroy();
    }
}
exports.ProtocolRAW = ProtocolRAW;
//# sourceMappingURL=raw.js.map