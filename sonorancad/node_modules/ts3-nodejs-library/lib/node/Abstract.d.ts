import { TeamSpeak } from "../TeamSpeak";
import { TeamSpeakQuery } from "../transport/TeamSpeakQuery";
export declare abstract class Abstract<T extends TeamSpeakQuery.ResponseEntry> {
    private namespace;
    private propcache;
    private parent;
    constructor(parent: TeamSpeak, props: T, namespace: string);
    /** retrieves the namespace of this class */
    getNameSpace(): string;
    /** returns JSONifyable data */
    toJSON(includeNameSpace?: boolean): Record<string, any>;
    /**
     * retrieves a single property value by the given name
     * @param name the name from where the value should be retrieved
     */
    getPropertyByName<Y extends keyof T>(name: Y): T[Y];
    /** updates the cache with the given object */
    updateCache(props: TeamSpeakQuery.ResponseEntry): this;
    /** returns the parent class */
    getParent(): TeamSpeak;
}
