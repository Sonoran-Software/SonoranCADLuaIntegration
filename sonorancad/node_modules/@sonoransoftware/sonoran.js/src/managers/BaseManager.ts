import { Instance } from '../instance/Instance';

/**
 * Manages the API methods of a data model or a specific product methods.
 * @abstract
 */
export abstract class BaseManager {
  /**
   * 
   * @param {Instance} instance The instance that instantiated this Manager
   * @readonly
   */
  constructor(public readonly instance: Instance) {
  }
}
