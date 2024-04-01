import type { RequestInit } from 'node-fetch';
import type { APIData } from '../RequestManager';

export interface IHandler {
	queueRequest: (
		url: string,
		options: RequestInit,
		data: APIData,
	) => Promise<unknown>;
	// eslint-disable-next-line @typescript-eslint/method-signature-style -- This is meant to be a getter returning a bool
	get inactive(): boolean;
	readonly id: string;
}