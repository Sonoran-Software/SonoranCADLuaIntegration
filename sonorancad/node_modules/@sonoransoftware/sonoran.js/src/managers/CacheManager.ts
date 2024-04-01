import { Collection } from '@discordjs/collection';
import { Instance } from '../instance/Instance';
import { Constructable } from '../constants';
import { DataManager } from './DataManager';

export class CacheManager<K, Holds, R> extends DataManager<K, Holds, R> {
  public _cache: Collection<any, any> | never;
  protected constructor(instance: Instance, holds: Constructable<Holds>, iterable: Iterable<any>) {
    super(instance, holds);
    this._cache = new Collection();
    if (iterable) {
      for (const item of iterable) {
        this._add(item);
      }
    }
  }

  get cache() {
    return this._cache;
  }

  _add(data: any, cache: boolean = true, id?: K) {
    const existing = this.cache.get(id ?? data.id);
    if (existing) {
      if (cache) {
        existing._patch(data);
        return existing;
      }
      const clone = existing._clone();
      clone._patch(data);
      return clone;
    }

    const entry = data;
    if (cache) this.cache.set(id ?? entry.id, entry);
    return entry;
  }
}