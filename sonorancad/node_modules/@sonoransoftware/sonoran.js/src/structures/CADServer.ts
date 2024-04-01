import { Instance } from '../instance/Instance';
// import { CADActiveUnitsManager } from '../managers/CADActiveUnitsManager';
import { Base } from './Base';

export interface CADServerData {
  id: number;
  config: CADServerConfig;
}

export interface CADServerConfig {
  id: number;
  name: string;
  description: string;
  signal: null;
  mapUrl: string;
  mapIp: string;
  mapPort: string;
  differingOutbound: boolean;
  outboundIp: string;
  listenerPort: string;
  enableMap: boolean;
  mapType: string;
  isStatic: boolean;
}

export class CADServer extends Base {
  public id: number;
  public config!: CADServerConfig;
  // public units!: CADActiveUnitsManager; 
  
  constructor(instance: Instance, data: CADServerData) {
    super(instance);
    this.id = data.id;
    this.config = data.config;
    // this.units = new CADActiveUnitsManager(instance, [], this.id);
  }
}