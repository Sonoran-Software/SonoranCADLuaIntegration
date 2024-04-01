const messages = new Map();

export class GenericError extends Error {
  private readonly errCode: string;
  constructor(key: string, ...args: Array<any>) {
    super(GenericError.message(key, args));
    this.errCode = key;
    if (Error.captureStackTrace) Error.captureStackTrace(this, GenericError);
  }

  get name(): string {
    return `${super.name} [${this.errCode}]`;
  }

  get code(): string {
    return this.errCode;
  }

  /**
   * Format the message for an error.
   * @param {string} key Error key
   * @param {Array<any>} args Arguments to pass for util format or as function args
   * @returns {string} Formatted string
   */
  private static message(key: string, args: Array<any>): string {
    if (typeof key !== 'string') throw new Error('Error message key must be a string');
    const msg = messages.get(key);
    if (!msg) throw new Error(`An invalid error message key was used: ${key}.`);
    if (typeof msg === 'function') return msg(...args);
    if (!args?.length) return msg;
    args.unshift(msg);
    return String(...args);
  }
}

/**
 * Register an error code and message.
 * @param {string} sym Unique name for the error
 * @param {*} val Value of the error
 */
export function register(sym: symbol, val: any): void {
  messages.set(sym, typeof val === 'function' ? val : String(val));
}