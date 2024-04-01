import EventEmitter from 'events';

import * as globalTypes from '../constants';
import * as InstanceTypes from './instance.types';
import { CADManager } from '../managers/CADManager';
import { CMSManager } from '../managers/CMSManager';
import { debugLog } from '../utils';

export class Instance extends EventEmitter {
  public cadCommunityId: string | undefined;
  public cadApiKey: string | undefined;
  public cadApiUrl: string = 'https://api.sonorancad.com';
  public cadDefaultServerId: number = 1;
  public isCADSuccessful: boolean = false;
  public cmsCommunityId: string | undefined;
  public cmsApiKey: string | undefined;
  public cmsApiUrl: string = 'https://api.sonorancms.com';
  public cmsDefaultServerId: number = 1;
  public isCMSSuccessful: boolean = false;

  public cad: CADManager | undefined;
  public cms: CMSManager | undefined;

  public debug: boolean = false;
  public apiHeaders: HeadersInit = {};

  constructor(options: InstanceTypes.InstanceOptions) {
    super({ captureRejections: true });
    if (options.debug) {
      this.debug = options.debug;
    }
    if (Object.prototype.hasOwnProperty.call(options, 'apiHeaders') && options.apiHeaders !== undefined) {
      this.apiHeaders = options.apiHeaders;
    }
    if (Object.prototype.hasOwnProperty.call(options, 'apiKey') && Object.prototype.hasOwnProperty.call(options, 'communityId')) {
      if (Object.prototype.hasOwnProperty.call(options, 'product')) {
        switch (options.product) {
          case globalTypes.productEnums.CAD: {
            this.cadCommunityId = options.communityId;
            this.cadApiKey = options.apiKey;
            if (options.serverId !== undefined) {
              this._debugLog(`Overriding default server id... ${options.serverId}`);
              this.cadDefaultServerId = options.serverId;
            }
            if (Object.prototype.hasOwnProperty.call(options, 'cadApiUrl') && typeof options.cadApiUrl === 'string') {
              this._debugLog(`Overriding CAD API Url... ${options.cadApiUrl}`);
              this.cadApiUrl = options.cadApiUrl;
            }
            this._debugLog('About to initialize instance.');
            this.initialize();
            break;
          }
          case globalTypes.productEnums.CMS: {
            this.cmsCommunityId = options.communityId;
            this.cmsApiKey = options.apiKey;
            if (options.serverId !== undefined) {
              this._debugLog(`Overriding default server id... ${options.serverId}`);
              this.cmsDefaultServerId = options.serverId;
            }
            if (Object.prototype.hasOwnProperty.call(options, 'cmsApiUrl') && typeof options.cmsApiUrl === 'string') {
              this._debugLog(`Overriding CMS API URL... ${options.cmsApiUrl}`);
              this.cmsApiUrl = options.cmsApiUrl;
            }
            this.initialize();
            break;
          }
          default: {
            throw new Error('Invalid product enum given for constructor.');
          }
        }
      } else {
        throw new Error('No product enum given when instancing.');
      }
    } else {
      this.cadCommunityId = options.cadCommunityId;
      this.cadApiKey = options.cadApiKey;
      this.cmsCommunityId = options.cmsCommunityId;
      this.cmsApiKey = options.cmsApiKey;

      if (options.cadDefaultServerId !== undefined) {
        this._debugLog(`Overriding default CAD server id... ${options.serverId}`);
        this.cadDefaultServerId = options.cadDefaultServerId;
      }
      if (options.cmsDefaultServerId !== undefined) {
        this._debugLog(`Overriding default CMS server id... ${options.serverId}`);
        this.cmsDefaultServerId = options.cmsDefaultServerId;
      }
      if (Object.prototype.hasOwnProperty.call(options, 'cadApiUrl') && typeof options.cadApiUrl === 'string') {
        this._debugLog(`Overriding CAD API Url... ${options.cadApiUrl}`);
        this.cadApiUrl = options.cadApiUrl;
      }
      if (Object.prototype.hasOwnProperty.call(options, 'cmsApiUrl') && typeof options.cmsApiUrl === 'string') {
        this._debugLog(`Overriding CMS API URL... ${options.cmsApiUrl}`);
        this.cmsApiUrl = options.cmsApiUrl;
      }
      this.initialize();
    }
  }



  private initialize() {
    if (this.cadCommunityId && this.cadApiKey && this.cadApiUrl) {
      this._debugLog('About to initialize CAD Manager');
      this.cad = new CADManager(this);
    } else {
      this._debugLog('Not initializing CAD Manager due to a missing community id, api key, or api url.');
    }
    if (this.cmsCommunityId && this.cmsApiKey && this.cmsApiUrl) {
      this._debugLog('About to initialize CMS Manager');
      this.cms = new CMSManager(this);
    } else {
      this._debugLog('Not initializing CMS Manager due to a missing community id, api key, or api url.');
    }
  }

  public _debugLog(message: string): void {
    if (this.debug) {
      debugLog(message);
    }
  }
}