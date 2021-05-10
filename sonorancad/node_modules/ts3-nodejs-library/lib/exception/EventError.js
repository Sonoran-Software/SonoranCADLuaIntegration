"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.EventError = void 0;
class EventError extends Error {
    /**
     * @param message error message
     * @param eventName source event of this error
     */
    constructor(message, eventName) {
        super(`${message} in event "${eventName}"`);
        this.eventName = eventName;
    }
    /* returns a string representation for the error */
    toString() {
        return this.message;
    }
    /* returns a json representation for this error */
    toJSON() {
        return {
            name: this.name,
            message: this.message,
            eventName: this.eventName
        };
    }
}
exports.EventError = EventError;
//# sourceMappingURL=EventError.js.map