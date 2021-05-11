/// <reference types="node" />
import { EventEmitter } from "events";
import { TeamSpeak } from "../../TeamSpeak";
import { TeamSpeakQuery } from "../TeamSpeakQuery";
export declare class ProtocolRAW extends EventEmitter implements TeamSpeakQuery.QueryProtocolInterface {
    private socket;
    chunk: string;
    constructor(config: TeamSpeak.ConnectionParams);
    /**
     * Called after the socket was not able to connect within the given timeframe
     */
    private handleTimeout;
    /**
     * Called after the Socket has been established
     */
    private handleConnect;
    /**
     * called when the Socket emits an error
     */
    private handleError;
    /**
     * called when the connection with the Socket gets closed
     */
    private handleClose;
    /**
     * called when the Socket receives data
     * Splits the data with every newline
     */
    private handleData;
    send(str: string): void;
    sendKeepAlive(): void;
    close(): void;
}
