import { EventEmitter } from 'events';
import {
	InternalRequestData,
	// RequestMethod,
	RequestData,
	RequestManager,
	// RouteLike
} from './RequestManager';
import { AllAPITypes, AllAPITypesType, RESTEvents, RESTTypedAPIDataStructs } from './utils/constants';
import { productEnums, uuidRegex } from '../../../../constants';
import type { AgentOptions } from 'node:https';
import type { RequestInit, Response } from 'node-fetch';
// import type Collection from '@discordjs/collection';
import { Instance } from '../../../../instance/Instance';
import { CADManager } from '../../../../managers/CADManager';
import { CMSManager } from '../../../../managers/CMSManager';

/**
 * Options to be passed when creating the REST instance
 */
export interface RESTOptions {
	/**
	 * HTTPS Agent options
	 * @default {}
	 */
	agent: Omit<AgentOptions, 'keepAlive'>;
	/**
	 * The base api path, without version
	 */
	api: string;
	/**
	 * Additional headers to send for all API requests
	 * @default {}
	 */
	headers: Record<string, string>;
	/**
	 * Wether the request should be queued if there's a current ratelimit or to reject.
	 * @default true
	 */
	 rejectOnRateLimit: boolean;
}

/**
 * Data emitted on `RESTEvents.RateLimited`
 */
export interface RateLimitData {
	product: productEnums;
  type: string;
  timeTill: NodeJS.Timer;
}

export interface APIRequest {
	/**
	 * The HTTP method used in this request
	 */
	type: AllAPITypesType;
	/**
	 * Additional HTTP options for this request
	 */
	options: RequestInit;
	/**
	 * The data that was used to form the body of this request
	 */
	data: RequestData;
}

export interface InvalidRequestWarningData {
	/**
	 * Number of invalid requests that have been made in the window
	 */
	count: number;
	/**
	 * API request type which the request is for
	 */
	type: string;
	/**
	 * Product which the invalid request is for
	 */
	product: productEnums;
}

export interface RestEvents {
	invalidRequestWarning: [invalidRequestInfo: InvalidRequestWarningData];
	restDebug: [info: string];
	rateLimited: [rateLimitInfo: RateLimitData];
	request: [request: APIRequest];
	response: [request: APIRequest, response: Response];
	newListener: [name: string, listener: (...args: any) => void];
	removeListener: [name: string, listener: (...args: any) => void];
}

export interface REST {
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

export type RestManagerTypes = CADManager | CMSManager;

export class REST extends EventEmitter {
	public readonly requestManager: RequestManager;
	public readonly instance: Instance;
	public readonly manager: RestManagerTypes;

	public constructor(_instance: Instance, _manager: RestManagerTypes,_product: productEnums, options: RESTOptions) {
		super();
		this.instance = _instance;
		this.manager = _manager;
		this.requestManager = new RequestManager(_instance, _product, options)
			.on(RESTEvents.Debug, this.emit.bind(this, RESTEvents.Debug))
			.on(RESTEvents.RateLimited, this.emit.bind(this, RESTEvents.RateLimited))
			.on(RESTEvents.InvalidRequestWarning, this.emit.bind(this, RESTEvents.InvalidRequestWarning));

		this.on('newListener', (name, listener) => {
			if (name === RESTEvents.Request || name === RESTEvents.Response) this.requestManager.on(name, listener);
		});
		this.on('removeListener', (name, listener) => {
			if (name === RESTEvents.Request || name === RESTEvents.Response) this.requestManager.off(name, listener);
		});
	}

	/**
	 * Runs a request from the api
	 * @param type API Type Enum
	 */
	public request<K extends keyof RESTTypedAPIDataStructs>(type: K, ...args: RESTTypedAPIDataStructs[K]) {
		const apiType = AllAPITypes.find((aT) => aT.type === type);
		if (!apiType) throw new Error('Invalid API Type given for request.');
		let communityId: string | undefined;
		let apiKey: string | undefined;
		switch (apiType.product) {
			case productEnums.CAD: {
				communityId = this.instance.cadCommunityId;
				apiKey = this.instance.cadApiKey;
				break;
			}
			case productEnums.CMS: {
				communityId = this.instance.cmsCommunityId;
				apiKey = this.instance.cmsApiKey;
				break;
			}
		}
		if (!communityId || !apiKey) throw new Error(`Community ID or API Key could not be found for request. P${apiType.product}`);
		// if (apiType.minVersion > this.manager.version) throw new Error(`[${type}] Subscription version too low for this API type request. Current Version: ${convertSubNumToName(this.manager.version)} Needed Version: ${convertSubNumToName(apiType.minVersion)}`);  // Verifies API Subscription Level Requirement which is deprecated currently
		const formattedData = this.formatDataArguments(apiType.type, args);
		const options: InternalRequestData = {
			id: communityId,
			key: apiKey,
			type,
			data: formattedData,
			product: apiType.product
		};
		return this.requestManager.queueRequest(options);
	}

	private formatDataArguments(type: string, args: any) {
		switch (type) {
			case 'VERIFY_WHITELIST': {
				return {
					apiId: args[0],
					accId: uuidRegex.test(args[1]) ? args[1] : undefined,
					serverId: args[2],
					discord: args[3]
				}
			}
			case 'FULL_WHITELIST': {
				return {
					serverId: args[0]
				}
			}
			case 'RSVP': {
				return {
					eventId: args[0],
					apiId: args[1],
					accId: args[2],
					discord: args[3],
					uniqueId: args[4]
				}
			}
			case 'GET_COM_ACCOUNT': {
				return {
					apiId: args[0],
					username: args[1],
					accId: args[2],
					discord: args[3],
					uniqueId: args[4]
				};
			}
			case 'GET_ACCOUNT_RANKS': {
				return {
					apiId: args[0],
					username: args[1],
					accId: args[2],
					discord: args[3],
					uniqueId: args[4]
				};
			}
			case 'CLOCK_IN_OUT': {
				return {
					apiId: args[0],
					accId: args[1],
					forceClockIn: args[2],
					discord: args[3],
					uniqueId: args[4]
				};
			}
			case 'CHECK_COM_APIID': {
				return {
					apiId: args[0]
				};
			}
			case 'SET_ACCOUNT_RANKS': {
				return {
					accId: args[0],
					set: args[1],
					add: args[2],
					remove: args[3],
					apiId: args[4],
					username: args[5],
					discord: args[6],
					uniqueId: args[7],
				};
			}
			case 'VERIFY_SECRET': {
				return {
					secret: args[0],
				};
			}
			case 'CHANGE_FORM_STAGE': {
				return {
					accId: args[0],
					formId: args[1],
					newStageId: args[2],
					apiId: args[3],
					username: args[4],
					discord: args[5],
					uniqueId: args[6],
				};
			}
			case 'BAN_ACCOUNT': {
				return {
					apiId: args[0],
					accId: args[1],
					discord: args[2],
					uniqueId: args[3]
				};
			}
			case 'KICK_ACCOUNT': {
				return {
					apiId: args[0],
					accId: args[1],
					discord: args[2],
					uniqueId: args[3]
				};
			}
			case 'LOOKUP': {
				return {
					id: args[0],
					uuid: args[1]
				}
			}
			case 'EDIT_ACC_PROFLIE_FIELDS': {
				return {
					apiId: args[0],
					username: args[1],
					accId: args[2],
					discord: args[3],
					uniqueId: args[4],
					profileFields: args[5]
				}
			}
			default: {
				return args;
			}
		}
	}
}
