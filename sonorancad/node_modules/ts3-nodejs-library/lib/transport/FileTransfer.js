"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.FileTransfer = void 0;
const net_1 = require("net");
class FileTransfer {
    /**
     * Initializes a File Transfer
     * @param host TeamSpeak's File transfer Host
     * @param port TeamSpeak's File transfer Port
     * @param timeout Timeout for File Transfer
     */
    constructor(host, port = 30033, timeout = 8000) {
        this.bytesreceived = 0;
        this.host = host;
        this.port = port;
        this.timeout = timeout;
        this.bytesreceived = 0;
        this.buffer = [];
    }
    /**
     * Starts the download of a File
     * @param ftkey the Filetransfer Key
     * @param size the Data Length
     */
    download(ftkey, size) {
        return new Promise((fulfill, reject) => {
            this.init(ftkey)
                .then(({ socket, timeout }) => {
                socket.once("error", reject);
                socket.on("data", (data) => {
                    this.buffer.push(data);
                    this.bytesreceived += data.byteLength;
                    if (this.bytesreceived === size) {
                        socket.destroy();
                        clearTimeout(timeout);
                        fulfill(Buffer.concat(this.buffer));
                    }
                });
            })
                .catch(reject);
        });
    }
    /**
     * starts the upload of a File
     * @param ftkey the Filetransfer Key
     * @param data the data to send
     */
    upload(ftkey, data) {
        return new Promise((fulfill, reject) => {
            this.init(ftkey)
                .then(({ socket, timeout }) => {
                socket.once("error", reject);
                socket.on("close", () => {
                    clearTimeout(timeout);
                    socket.removeListener("error", reject);
                    fulfill();
                });
                socket.write(data);
            })
                .catch(reject);
        });
    }
    /**
     * connects to the File Transfer Server
     * @param ftkey the Filetransfer Key
     * @returns returns a Promise Object with the socket
     */
    init(ftkey) {
        return new Promise((fulfill, reject) => {
            const socket = new net_1.Socket();
            const timeout = setTimeout(() => {
                socket.destroy();
                reject(new Error("Filetransfer Timeout Limit reached"));
            }, this.timeout);
            socket.connect(this.port, this.host);
            socket.on("connect", () => {
                if (typeof ftkey === "string")
                    socket.write(ftkey);
                socket.removeListener("error", reject);
                fulfill({ socket, timeout });
            });
            socket.once("error", reject);
        });
    }
}
exports.FileTransfer = FileTransfer;
//# sourceMappingURL=FileTransfer.js.map