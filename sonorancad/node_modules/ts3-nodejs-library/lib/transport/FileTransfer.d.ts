/// <reference types="node" />
export declare class FileTransfer {
    private bytesreceived;
    private host;
    private port;
    private buffer;
    private timeout;
    /**
     * Initializes a File Transfer
     * @param host TeamSpeak's File transfer Host
     * @param port TeamSpeak's File transfer Port
     * @param timeout Timeout for File Transfer
     */
    constructor(host: string, port?: number, timeout?: number);
    /**
     * Starts the download of a File
     * @param ftkey the Filetransfer Key
     * @param size the Data Length
     */
    download(ftkey: string, size: number): Promise<Buffer>;
    /**
     * starts the upload of a File
     * @param ftkey the Filetransfer Key
     * @param data the data to send
     */
    upload(ftkey: string, data: string | Buffer): Promise<void>;
    /**
     * connects to the File Transfer Server
     * @param ftkey the Filetransfer Key
     * @returns returns a Promise Object with the socket
     */
    private init;
}
