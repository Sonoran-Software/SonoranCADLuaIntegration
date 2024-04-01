// import { setTimeout as sleep } from 'node:timers/promises';
import { AsyncQueue } from '@sapphire/async-queue';
import fetch, { RequestInit, Response } from 'node-fetch';
import { AbortController } from "node-abort-controller";
// import { DiscordAPIError, DiscordErrorData, OAuthErrorData } from '../errors/DiscordAPIError';
import { APIError } from '../errors';
import { HTTPError } from '../errors/HTTPError';
// import { RateLimitError } from '../errors/RateLimitError';
import type { RequestManager, APIData, /**RequestData*/ } from '../RequestManager';
import { RateLimitData } from '../REST';
// import { RESTEvents } from '../utils/constants';
// import type { RateLimitData } from '../REST';
import type { IHandler } from './IHandler';

export class SequentialHandler implements IHandler {
	/**
	 * The unique id of the handler
	 */
	public readonly id: string;

	/**
	 * The total number of requests that can be made before we are rate limited
	 */
	// private limit = Infinity;

	/**
	 * The interface used to sequence async requests sequentially
	 */
	// eslint-disable-next-line @typescript-eslint/explicit-member-accessibility
	#asyncQueue = new AsyncQueue();

	/**
	 * @param manager The request manager
	 * @param hash The hash that this RequestHandler handles
	 * @param majorParameter The major parameter for this handler
	 */
	public constructor(
		private readonly manager: RequestManager,
		private readonly data: APIData,
	) {
		this.id = `${this.data.typePath}:${String(this.data.product)}`;
	}

	/**
	 * If the bucket is currently inactive (no pending requests)
	 */
	public get inactive(): boolean {
		return (
			this.#asyncQueue.remaining === 0
		);
	}

	public getMang(): RequestManager {
		return this.manager;
	}

	/**
	 * Emits a debug message
	 * @param message The message to debug
	 */
	// private debug(message: string) {
	// 	this.manager.emit(RESTEvents.Debug, `[REST ${this.id}] ${message}`);
	// }

	/*
	 * Determines whether the request should be queued or whether a RateLimitError should be thrown
	 */
	// private async onRateLimit(rateLimitData: RateLimitData) {
	// 	const { options } = this.manager;
	// 	if (options.rejectOnRateLimit) {
	// 		throw new RateLimitError(rateLimitData);
	// 	}
	// }

	/**
	 * Queues a request to be sent
	 * @param routeId The generalized api route with literal ids for major parameters
	 * @param url The url to do the request on
	 * @param options All the information needed to make a request
	 * @param requestData Extra data from the user's request needed for errors and additional processing
	 */
	public async queueRequest(
		url: string,
		options: RequestInit,
    data: APIData
	): Promise<unknown> {
		let queue = this.#asyncQueue;
		// Wait for any previous requests to be completed before this one is run
		await queue.wait();
		try {
			// Make the request, and return the results
			return await this.runRequest(url, options, data);
		} finally {
			// Allow the next request to fire
			queue.shift();
		}
	}

	/**
	 * The method that actually makes the request to the api, and updates info about the bucket accordingly
	 * @param routeId The generalized api route with literal ids for major parameters
	 * @param url The fully resolved url to make the request to
	 * @param options The node-fetch options needed to make the request
	 * @param requestData Extra data from the user's request needed for errors and additional processing
	 * @param retries The number of retries this request has already attempted (recursion)
	 */
	private async runRequest(
		url: string,
		options: RequestInit,
    data: APIData,
		// retries = 0,
	): Promise<unknown> {
		const controller = new AbortController();
		const timeout = setTimeout(() => controller.abort(), 30000).unref();
		let res: Response;

		void this.manager.debug(`[${url} Request] - ${JSON.stringify({ url, options, data })}`);

		try {
			// node-fetch typings are a bit weird, so we have to cast to any to get the correct signature
			// Type 'AbortSignal' is not assignable to type 'import('discord.js-modules/node_modules/@types/node-fetch/externals').AbortSignal'
			// eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
			res = await fetch(url, { ...options, signal: controller.signal as any });
		} catch (error: unknown) {
			throw error;
		} finally {
			clearTimeout(timeout);
		}

		const parsedRes = await SequentialHandler.parseResponse(res);

		void this.manager.debug(`[${url} Response] - ${JSON.stringify({ body: parsedRes, res, status: res.status, headers: res.headers })}`);

		if (res.ok) {
			return parsedRes;
		} else if (res.status === 400 || res.status === 401 || res.status === 404) {
			throw new APIError(parsedRes as string, data.type, data.fullUrl, res.status, data);
		} else if (res.status === 429) {
			const timeout = setTimeout(() => {
				this.manager.removeRateLimit(data.requestTypeId);
			}, 60 * 1000);
			const ratelimitData: RateLimitData = {
				product: data.product,
				type: data.type,
				timeTill: timeout
			};
			this.manager.onRateLimit(data.requestTypeId, ratelimitData);
		} else if (res.status >= 500 && res.status < 600) {
			throw new HTTPError(res.statusText, res.constructor.name, res.status, data.method, url);
		}
    return null;
	}

	private static parseResponse(res: Response): Promise<unknown> {
		if (res.headers.get('Content-Type')?.startsWith('application/json')) {
			return res.json();
		}
	
		return res.text();
	}
}