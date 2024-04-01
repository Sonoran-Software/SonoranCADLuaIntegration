import { Instance } from '../instance/Instance';
import { Base } from './Base';

export interface CMSServerData {
  id: number;
  config: CMSServerConfig;
}

export interface CMSServerConfig {
  id: number;
  name: string;
  description: string;
  allowedRanks: string[];
  blockedRanks: string[];
}

export class CMSServer extends Base {
  public id: number;
  public config!: CMSServerConfig;
  
  constructor(instance: Instance, data: CMSServerData) {
    super(instance);
    this.id = data.id;
    this.config = data.config;
  }
}