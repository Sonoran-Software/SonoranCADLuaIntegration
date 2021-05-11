/// <reference types="node" />
import { EventEmitter } from "events";
import { TeamSpeak } from "../../TeamSpeak";
import { TeamSpeakQuery } from "../TeamSpeakQuery";
export declare class ProtocolSSH extends EventEmitter implements TeamSpeakQuery.QueryProtocolInterface {
    private client;
    private stream;
    chunk: string;
    constructor(config: TeamSpeak.ConnectionParams);
    /**
     * Called after the Socket has been established
     */
    private handleReady;
    /**
     * Called when the connection with the Socket gets closed
     */
    private handleClose;
    /**
     * Called when the Socket emits an error
     */
    private handleError;
    /**
     * called when the Socket receives data
     */
    private handleData;
    send(str: string): void;
    sendKeepAlive(): void;
    close(): void;
}
