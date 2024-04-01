import { Instance } from '../instance/Instance';
import { CMSServerAPIStruct } from '../libs/rest/src';
import { CMSServer } from '../structures/CMSServer';
import { CacheManager } from './CacheManager';
import { CMSManager } from './CMSManager';

export class CMSServerManager extends CacheManager<number, CMSServer, CMSServerAPIStruct> {
  constructor(instance: Instance, manager: CMSManager) {
    super(instance, CMSServer, []);

    (async () => {
      while(!manager.ready) {
        await new Promise((resolve) => {
          setTimeout(resolve, 100);
        });
      } 
      try {
        const serversRes: any = await manager.rest?.request('GET_GAME_SERVERS');
        const servers = serversRes.servers;
        servers.forEach((server: CMSServerAPIStruct) => {
          const serverStruct = {
            id: server.id,
            config: server
          };
          this._add(serverStruct, true, server.id);
        });
        console.log(`Found ${servers.length} servers`);
      } catch (err) {
        throw new Error(String(err));
      }
    })();
  }
}