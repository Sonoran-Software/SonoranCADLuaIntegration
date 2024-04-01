import { Collection } from '@discordjs/collection';
// import { DiscordSnowflake } from '@sapphire/snowflake';
import { EventEmitter } from 'events';
// import type { RequestInit, BodyInit } from 'node-fetch';

import type { Instance } from '../../../../instance/Instance';
import { RESTOptions, RateLimitData, RestEvents } from './REST';
import { DefaultCADRestOptions, DefaultCMSRestOptions, AllAPITypes/**, RESTTypedAPIDataStructs, PossibleRequestData*/ } from './utils/constants';
import { productEnums } from '../../../../constants';
// import { APIError, HTTPError } from './errors';
import { IHandler } from './handlers/IHandler';
import { SequentialHandler } from './handlers/SequentialHandler';
import { cloneObject } from '../../../../utils/utils';

export type RouteLike = `/${string}`;

export const enum RequestMethod {
	Delete = 'delete',
	Get = 'get',
	Patch = 'patch',
	Post = 'post',
	Put = 'put',
}

export type ReqDataType = Array<unknown> | unknown;

export interface RequestData {
  id: string;
  key: string;
  type: string;
  data: any;
}

export interface InternalRequestData extends RequestData {
  product: productEnums;
}

export interface RequestHeaders {
  'User-Agent': string;
}

export interface APIData {
  requestTypeId: string;
  typePath: string;
  fullUrl: string;
  method: string;
  fetchOptions: RequestInit;
  data: RequestData;
  product: productEnums;
  type: string;
}

export interface RequestManager {
	on: (<K extends keyof RestEvents>(event: K, listener: (...args: RestEvents[K]) => void) => this) &
		(<S extends string | symbol>(event: Exclude<S, keyof RestEvents>, listener: (...args: any[]) => void) => this);

	once: (<K extends keyof RestEvents>(event: K, listener: (...args: RestEvents[K]) => void) => this) &
		(<S extends string | symbol>(event: Exclude<S, keyof RestEvents>, listener: (...args: any[]) => void) => this);

	emit: (<K extends keyof RestEvents>(event: K, ...args: RestEvents[K]) => boolean) &
		(<S extends string | symbol>(event: Exclude<S, keyof RestEvents>, ...args: any[]) => boolean);

	off: (<K extends keyof RestEvents>(event: K, listener: (...args: RestEvents[K]) => void) => this) &
		(<S extends string | symbol>(event: Exclude<S, keyof RestEvents>, listener: (...args: any[]) => void) => this);

	removeAllListeners: (<K extends keyof RestEvents>(event?: K) => this) &
		(<S extends string | symbol>(event?: Exclude<S, keyof RestEvents>) => this);
}

export class RequestManager extends EventEmitter {
  public readonly ratelimitedTypes = new Collection<string, RateLimitData>();
  public readonly handlers = new Collection<string, IHandler>();
  public readonly product: productEnums;
  public readonly options: RESTOptions;
  private instance: Instance;

  constructor(_instance: Instance, _product: productEnums, options: RESTOptions) {
    super();
    this.product = _product;
    this.instance = _instance;
    switch (_product) {
      case productEnums.CAD: {
        this.options = { ...DefaultCADRestOptions, ...options };
        break;
      }
      case productEnums.CMS: {
        this.options = { ...DefaultCMSRestOptions, ...options };
        break;
      }
      default: {
        throw new Error('No Product provided for RequestManager initialization');
      }
    }
  }

  public async queueRequest(request: InternalRequestData): Promise<unknown> {
    let requestData = request as RequestData;
    const resolvedData: APIData = RequestManager.resolveRequestData(this.instance, request.type, request.product, requestData);
    const handler = this.handlers.get(`${resolvedData.typePath}:${String(request.product)}`) ?? this.createHandler(resolvedData);
    return handler.queueRequest(resolvedData.fullUrl, resolvedData.fetchOptions as any, resolvedData);
  }

  public onRateLimit(id: string, rateLimitData: RateLimitData): void {
    this.ratelimitedTypes.set(id, rateLimitData);
  }

  public removeRateLimit(id: string): void {
    this.ratelimitedTypes.delete(id);
  }

  private createHandler(data: APIData) {
    const queue = new SequentialHandler(this, data);
    this.handlers.set(queue.id, queue);
    return queue;
  }

  private static resolveRequestData(instance: Instance, type: string, product: productEnums, data: RequestData): APIData {
    let apiURL: string | boolean = false;
    let apiData: APIData = {
      requestTypeId: `${type}:${String(product)}`,
      typePath: '',
      fullUrl: '',
      method: '',
      fetchOptions: {},
      data,
      product,
      type
    };

    switch (product) {
      case productEnums.CAD:
        apiURL = instance.cadApiUrl;
        break;
      case productEnums.CMS:
        apiURL = instance.cmsApiUrl;
        break;
    }

    const findType = AllAPITypes.find((_type) => _type.type === type);
    if (findType) {
      apiData.fullUrl = `${apiURL}/${findType.path}`;
      apiData.method = findType.method;
      apiData.fetchOptions.method = findType.method;
      apiData.typePath = findType.path;

      const clonedData = cloneObject(data.data);

      switch (findType.type) {
        case 'SET_SERVERS': {
          apiData.data.data = clonedData;
          break;
        }
        case 'SET_PENAL_CODES': {
          apiData.data.data = [clonedData[0]];
          break;
        }
        case 'SET_API_ID': {
          apiData.data.data = [clonedData[0]];
          break;
        }
        case 'NEW_RECORD': {
          apiData.data.data = [clonedData[0]];
          break;
        }
        case 'EDIT_RECORD': {
          apiData.data.data = [clonedData[0]];
          break;
        }
        case 'LOOKUP_INT': {
          apiData.data.data = [clonedData[0]];
          break;
        }
        case 'LOOKUP': {
          apiData.data.data = [clonedData[0]];
          break;
        }
        case 'SET_ACCOUNT_PERMISSIONS': {
          apiData.data.data = [clonedData[0]];
          break;
        }
        case 'BAN_USER': {
          apiData.data.data = [clonedData[0]];
          break;
        }
        case 'AUTH_STREETSIGNS': {
          apiData.data.data = clonedData;
          break;
        }
        case 'SET_POSTALS': {
          apiData.data.data = [clonedData[0]];
          break;
        }
        case 'NEW_CHARACTER': {
          apiData.data.data = [clonedData[0]];
          break;
        }
        case 'EDIT_CHARACTER': {
          apiData.data.data = [clonedData[0]];
          break;
        }
        case 'MODIFY_IDENTIFIER': {
          apiData.data.data = [clonedData[0]];
          break;
        }
        case 'ADD_BLIP': {
          apiData.data.data = [clonedData[0]];
          break;
        }
        case 'MODIFY_BLIP': {
          apiData.data.data = [clonedData[0]];
          break;
        }
        case 'GET_CALLS': {
          apiData.data.data = [clonedData[0]];
          break;
        }
        case 'GET_ACTIVE_UNITS': {
          apiData.data.data = [clonedData[0]];
          break;
        }
        case 'NEW_DISPATCH': {
          apiData.data.data = [clonedData[0]];
          break;
        }
        case 'UNIT_LOCATION': {
          apiData.data.data = [clonedData[0]];
          break;
        }
        default: {
          if (data.data) {
            if (Array.isArray(data.data)) {
              if (data.data.length > 0) {
                apiData.data.data = [ clonedData ];
              } else {
                apiData.data.data = [];
              }
            } else {
              apiData.data.data = [ clonedData ];
            }
          } else {
            apiData.data.data = [];
          }
          break;
        }
      }
    }

    apiData.fetchOptions.body = JSON.stringify(apiData.data);
    apiData.fetchOptions.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      ...instance.apiHeaders
    };

    return apiData;
  }

  debug(log: string) {
    return this.instance._debugLog(log);
  }
}