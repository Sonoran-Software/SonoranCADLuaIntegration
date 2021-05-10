/// <reference types="node" />
import { EventEmitter } from "events";
import { Command } from "./Command";
import { TeamSpeak } from "../TeamSpeak";
export declare class TeamSpeakQuery extends EventEmitter {
    static IGNORE_LINES_INITIAL: number;
    private config;
    private queue;
    private active;
    private ignoreLines;
    private lastEvent;
    private lastcmd;
    private connected;
    private keepAliveTimeout;
    private floodTimeout;
    private socket;
    private pauseQueue;
    readonly doubleEvents: string[];
    constructor(config: TeamSpeak.ConnectionParams);
    /**
     * start connecting to the teamspeak server
     */
    connect(): void;
    /** returns a constructed Socket */
    static getSocket(config: TeamSpeak.ConnectionParams): TeamSpeakQuery.QueryProtocolInterface;
    /** sends a command to the TeamSpeak Server */
    execute(command: string, ...args: TeamSpeakQuery.executeArgs[]): Promise<TeamSpeakQuery.Response[]>;
    /** sends a priorized command to the TeamSpeak Server */
    executePrio(command: string, ...args: TeamSpeakQuery.executeArgs[]): Promise<TeamSpeakQuery.Response[]>;
    /**
     * @param command command to send
     * @param args arguments which gets parsed
     * @param prio wether this command should be handled as priority and be queued before others
     */
    private handleCommand;
    /** forcefully closes the socket connection */
    forceQuit(): void;
    pause(pause: boolean): this;
    /** gets called when the underlying transport layer connects to a server */
    private handleConnect;
    /** handles a single line response from the teamspeak server */
    private handleLine;
    /** handles the error line which finnishes a command */
    private handleQueryError;
    /** handles a flooding response from the teamspeak query */
    private handleFloodingError;
    /**
     * Handles an event which has been received from the TeamSpeak Server
     * @param line event response line from the teamspeak server
     */
    private handleQueryEvent;
    /**
     * Emits an Error which the given arguments
     * @param {...any} args arguments which gets passed to the error event
     */
    private handleError;
    /** handles socket closing */
    private handleClose;
    /** handles the timer for the keepalive request */
    private keepAlive;
    /** dispatches the keepalive */
    private sendKeepAlive;
    /** executes the next command */
    private queueWorker;
    /**
     * retrieves the next available queue item
     * respects priorized queue
     */
    private getNextQueueItem;
    /** sends data to the socket */
    private send;
    isConnected(): boolean;
}
export declare namespace TeamSpeakQuery {
    type executeArgs = Command.ParserCallback | Command.multiOpts | Command.options | Command.flags;
    interface QueueItem {
        fulfill: (data: any) => void;
        reject: (data: any) => void;
        cmd: Command;
        priority: boolean;
    }
    interface QueryProtocolInterface extends EventEmitter {
        readonly chunk: string;
        /** sends a keepalive to the TeamSpeak Server */
        sendKeepAlive: () => void;
        /**
         * sends the data in the first argument, appends a newline
         * @param {string} str the data which should be sent
         */
        send: (data: string) => void;
        /** forcefully closes the socket */
        close: () => void;
    }
}
export declare namespace TeamSpeakQuery {
    type ValueTypes = boolean | string | string[] | number | number[] | undefined | TeamSpeakQuery.Response;
    interface ResponseEntry {
        [x: string]: ValueTypes;
    }
    type Response = ResponseEntry[];
}
