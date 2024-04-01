import type { RateLimitData } from '../REST';
import { productEnums } from '../../../../../constants';

export class RateLimitError extends Error implements RateLimitData {
	public product: productEnums;
	public type: string;
	public timeTill: NodeJS.Timer;
	public constructor({ product, type, timeTill }: RateLimitData) {
		super();
		this.product = product;
		this.type = type;
		this.timeTill = timeTill;
	}

	/**
	 * The name of the error
	 */
	public override get name(): string {
		return `Ratelimit Hit - [${this.product === productEnums.CAD ? 'Sonoran CAD' : this.product === productEnums.CMS ? 'Sonoran CMS' : 'Invalid Product' } '${this.type}']`;
	}
}