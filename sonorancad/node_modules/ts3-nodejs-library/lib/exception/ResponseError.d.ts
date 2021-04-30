import { QueryErrorMessage } from "../types/ResponseTypes";
export declare class ResponseError extends Error {
    readonly id: string;
    readonly msg: string;
    readonly extraMsg?: string;
    readonly failedPermid?: number;
    constructor(error: QueryErrorMessage, stack: string);
    /**
     * returns a string representative of this error
     */
    toString(): string;
    /**
     * returns a json encodeable object for this error
     */
    toJSON(): {
        id: string;
        msg: string;
        extraMsg: string | undefined;
        failedPermid: number | undefined;
        message: string;
    };
}
