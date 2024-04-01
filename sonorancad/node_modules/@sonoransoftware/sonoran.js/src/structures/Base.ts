import { Instance } from '../instance/Instance';
import { flatten } from '../utils';

export abstract class Base {
  public instance: Instance;
  constructor(instance: Instance) {
    this.instance = instance;
  }

  public _clone() {
    return Object.assign(Object.create(this), this);

  }

  public _patch(data: any) {
    return data;
  }

  public _update(data: any) {
    const clone = this._clone();
    this._patch(data);
    return clone;
  }

  public toJSON(...props: Record<string, boolean | string>[]): unknown {
    return flatten(this, ...props);
  }
}