import { Collection } from '@discordjs/collection';

const isObject = (d: any) => typeof d === 'object' && d !== null;

export function mergeDefault(def: any, given: any) {
  if (!given) return def;
  for (const key in def) {
    if (!Object.prototype.hasOwnProperty.call(given, key) || given[key] === undefined) {
      given[key] = def[key];
    } else if (given[key] === Object(given[key])) {
      given[key] = mergeDefault(def[key], given[key]);
    }
  }
  return given;
}

/**
 * Shallow-copies an object with its class/prototype intact.
 * @param {Object} obj Object to clone
 * @returns {Object}
 * @private
 */
export function cloneObject(obj: any) {
  return Object.assign(Object.create(obj), obj);
}

export function flatten(obj: any, ...props: any[]) {
  if (!isObject(obj)) return obj;

  const objProps: any[] = Object.keys(obj)
    .filter((k) => !k.startsWith('_'))
    .map((k) => ({ [k]: true }));

  props = objProps.length ? Object.assign([...objProps], ...props) : Object.assign({}, ...props); // eslint-disable-line

  const out: Record<any, any> = {};

  for (let [prop, newProp] of Object.entries(props)) {
    if (!newProp) continue;
    newProp = newProp === true ? prop : newProp;

    const element = obj[prop];
    const elemIsObj = isObject(element);
    const valueOf = elemIsObj && typeof element.valueOf === 'function' ? element.valueOf() : null;

    // If it's a Collection, make the array of keys
    if (element instanceof Collection) out[newProp] = Array.from(element.keys());
    // If the valueOf is a Collection, use its array of keys
    else if (valueOf instanceof Collection) out[newProp] = Array.from(valueOf.keys());
    // If it's an array, flatten each element
    else if (Array.isArray(element)) out[newProp] = element.map(e => flatten(e));
    // If it's an object with a primitive `valueOf`, use that value
    else if (typeof valueOf !== 'object') out[newProp] = valueOf;
    // If it's a primitive
    else if (!elemIsObj) out[newProp] = element;
  }

  return out;
}

export function warnLog(message: string): void {
  return console.log(`[Sonoran.js - DEBUG] ${message}`);
}

export function infoLog(message: string): void {
  return console.log(`[Sonoran.js - INFO] ${message}`);
}

export function errorLog(message: string): void {
  return console.log(`[Sonoran.js - ERROR] ${message}`);
}

export function debugLog(message: string): void {
  return console.log(`[Sonoran.js - DEBUG] ${message}`);
}