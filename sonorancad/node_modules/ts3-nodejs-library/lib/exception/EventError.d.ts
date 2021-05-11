export declare class EventError extends Error {
    readonly eventName: string;
    /**
     * @param message error message
     * @param eventName source event of this error
     */
    constructor(message: string, eventName: string);
    toString(): string;
    toJSON(): {
        name: string;
        message: string;
        eventName: string;
    };
}
