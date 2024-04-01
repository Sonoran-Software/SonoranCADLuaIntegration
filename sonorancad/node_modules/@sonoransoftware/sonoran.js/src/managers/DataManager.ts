import { Instance } from '../instance/Instance';
import { BaseManager } from './BaseManager';
import { GenericError } from '../errors';
import { Constructable } from '../constants';

import { Collection } from '@discordjs/collection';

interface DataManagerInstanceObject {
  id: string;
}

export class DataManager<_K, Holds, _R> extends BaseManager {
  public holds: Constructable<Holds>;

  constructor(instance: Instance, holds: any) {
    super(instance);

    /**
     * The data structure belonging to this manager.
     * @name DataManager#holds
     * @type {Function}
     * @private
     * @readonly
     */
    this.holds = holds;
  }

  /**
   * The cache of items for this manager.
   * @type {Collection}
   * @abstract
   */
  get cache(): Collection<any, any> {
    throw new GenericError('NOT_IMPLEMENTED', 'get cache', this.constructor.name);
  }

  /**
   * Resolves a data entry to a data Object.
   * @param idOrInstance The id or instance of something in this Manager
   * @returns {?Object} An instance from this Manager
   */
  public resolve(idOrInstance: string | object): object | null {
    if (this.cache instanceof Collection) {
      if (typeof idOrInstance === 'object') return idOrInstance;
      if (typeof idOrInstance === 'string') return this.cache.get(idOrInstance) ?? null;
    }
    return null;
  }

  /**
   * Resolves a data entry to an instance id.
   * @param {string|Object} idOrInstance The id or instance of something in this Manager
   * @returns {?Snowflake}
   */
  resolveId(idOrInstance: string | DataManagerInstanceObject): string | null {
    if (typeof idOrInstance === 'object') return idOrInstance.id;
    if (typeof idOrInstance === 'string') return idOrInstance;
    return null;
  }

  valueOf() {
    return this.cache;
  }
}