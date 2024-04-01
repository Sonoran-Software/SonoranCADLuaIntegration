import { Instance } from '../instance/Instance';
import { CADServerAPIStruct } from '../libs/rest/src';
import { CADServer } from '../structures/CADServer';
import { CacheManager } from './CacheManager';
import { CADManager } from './CADManager';

export class CADServerManager extends CacheManager<number, CADServer, CADServerAPIStruct> {
  constructor(instance: Instance, manager: CADManager) {
    super(instance, CADServer, []);

    (async () => {
      try {
        const serversRes: any = await manager.rest?.request('GET_SERVERS');
        const servers = JSON.parse(serversRes).servers;
        servers.forEach((server: CADServerAPIStruct) => {
          const serverStruct = {
            id: server.id,
            config: server
          };
          this._add(serverStruct, true, server.id);
        });
      } catch (err) {
        throw new Error(String(err));
      }
    })();
  }
}