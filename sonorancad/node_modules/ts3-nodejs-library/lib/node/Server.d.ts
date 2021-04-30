import { Abstract } from "./Abstract";
import { TeamSpeak } from "../TeamSpeak";
import { ServerEntry } from "../types/ResponseTypes";
export declare class TeamSpeakServer extends Abstract<ServerEntry> {
    constructor(parent: TeamSpeak, list: ServerEntry);
    get id(): string;
    get port(): number;
    get status(): string;
    get clientsonline(): number;
    get queryclientsonline(): number;
    get maxclients(): number;
    get uptime(): number;
    get name(): string;
    get autostart(): number;
    get machineId(): string;
    get uniqueIdentifier(): string;
    /**
     * selects a virtual server
     * @param client_nickname sets the nickname when selecting a server
     */
    use(clientNickname?: string): Promise<[]>;
    /** deletes the server */
    del(): Promise<[]>;
    /**
     * Starts the virtual server.
     * Depending on your permissions, you're able to start either your own virtual server only or all virtual servers in the server instance.
     */
    start(): Promise<[]>;
    /**
     * Stops the virtual server.
     * Depending on your permissions, you're able to stop either your own virtual server only or all virtual servers in the server instance.
     * @param msg specifies a text message that is sent to the clients before the client disconnects (requires TeamSpeak Server 3.2.0 or newer).
     */
    stop(msg?: string): Promise<[]>;
    /** retrieves the client id from a string or teamspeak client */
    static getId<T extends TeamSpeakServer.ServerType>(server?: T): T extends undefined ? undefined : string;
    /** retrieves the clients from an array */
    static getMultipleIds(servers: TeamSpeakServer.MultiServerType): string[];
}
export declare namespace TeamSpeakServer {
    type ServerType = string | TeamSpeakServer;
    type MultiServerType = string[] | TeamSpeakServer[] | ServerType;
}
