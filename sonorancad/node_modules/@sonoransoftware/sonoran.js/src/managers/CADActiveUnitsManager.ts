// Work in progress still...

// import { CADActiveUnitFetchOptions } from '../constants';
import { Instance } from '../instance/Instance';
import { CADActiveUnit, CADActiveUnitResolvable, CADActiveUnitStruct } from '../structures/CADActiveUnit';
import { CacheManager } from './CacheManager';

export class CADActiveUnitsManager extends CacheManager<number, CADActiveUnit, CADActiveUnitResolvable> {
  public serverId: number;
  public instance: Instance;
  constructor(instance: Instance, iterable: Iterable<CADActiveUnitStruct>, serverId: number) {
    super(instance, CADActiveUnit, iterable);
    this.instance = instance;
    this.serverId = serverId;
  }

  _add(data: any, cache = true) {
    return super._add(data, cache, data.id);
  }

  fetch(/*options: CADActiveUnitResolvable | CADActiveUnitFetchOptions**/) {
    // if (!options) return this._fetchMany();
    this._fetchSingle({
      unit: -1,
      includeOffline: false,
      force: false
    });
  }

  async _fetchSingle({
    unit,
    includeOffline = false,
    force = false
  }:{
    unit: CADActiveUnitResolvable;
    includeOffline: boolean;
    force: boolean;
  }) {
    if (!force) {
      const existing = this.cache.get(unit);
      if (existing) return existing;
    }

    const data = await this.instance.cad?.rest?.request('GET_ACTIVE_UNITS', {
      serverId: this.serverId,
      includeOffline
    });
    console.log(data);
  }
}