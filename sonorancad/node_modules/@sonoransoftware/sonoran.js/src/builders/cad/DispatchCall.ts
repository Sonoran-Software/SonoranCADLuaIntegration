import { CADNewDispatchBuilderOptions } from '../../constants';
import { CADDispatchOriginEnums, CADDispatchStatusEnums } from '../../libs/rest/src';

/**
 * Represents a constructed dispatch call for API requests
 */
export class DispatchCallBuilder {
  public readonly data: CADNewDispatchBuilderOptions;

  /**
   * Dispatch Call Builder used for API calls with Sonoran CAD to create a new dispatch call.
   * @param data Data Options (CADNewDispatchBuilderOptions) used to build the new dispatch call
   */
  public constructor(data: CADNewDispatchBuilderOptions = {}) {
    this.data = { ...data };
  }

  /**
	 * Sets the origin for this dispatch call
   * @param origin Origin enum used for this dispatch call for information purposes
	 */
  public setOrigin(origin: CADDispatchOriginEnums): this {
    this.data.origin = origin;
    return this;
  }

  /**
	 * Sets the status for this dispatch call
   * @param status Status enum used for the dispatch call for information purposes
	 */
  public setStatus(status: CADDispatchStatusEnums): this {
    this.data.status = status;
    return this;
  }

  /**
	 * Sets the priority level for this dispatch call
   * @param priority Priority level used for the dispatch call for information purposes
	 */
  public setPriority(priority: 1 | 2 | 3): this {
    this.data.priority = priority;
    return this;
  }

  /**
	 * Sets the block for this dispatch call
   * @param block Block used for the dispatch call for information purposes
	 */
  public setBlock(block: string): this {
    this.data.block = block;
    return this;
  }

  /**
	 * Sets the address for this dispatch call
   * @param address Address used for the dispatch call for information purposes
	 */
  public setAddress(address: string): this {
    this.data.address = address;
    return this;
  }

  /**
	 * Sets the postal for this dispatch call
   * @param postal Postal used for the dispatch call for information purposes
	 */
  public setPostal(postal: string): this {
    this.data.postal = postal;
    return this;
  }

  /**
	 * Sets the title for this dispatch call
   * @param title Title used for the dispatch call for information purposes
	 */
  public setTitle(title: string): this {
    this.data.title = title;
    return this;
  }

  /**
	 * Sets the code for this dispatch call
   * @param code Code used for the dispatch call for information purposes
	 */
  public setCode(code: string): this {
    this.data.code = code;
    return this;
  }

  /**
	 * Sets the primary tracking preference for this dispatch call
   * @param primaryUnit Primary unit identifier
	 */
  public setPrimary(primaryUnit: number): this {
    this.data.primary = primaryUnit;
    return this;
  }

  /**
	 * Sets the track primary preference for this dispatch call
   * @param preference Preference for tracking primary
	 */
  public setTrackPrimaryPreference(preference: boolean): this {
    this.data.trackPrimary = preference;
    return this;
  }

  /**
	 * Sets the description for this dispatch call
   * @param description Description for a dispatch call
	 */
  public setDescription(description: string): this {
    this.data.description = description;
    return this;
  }

  /**
	 * Sets metadata for this dispatch call that can be used later on
   * @param metaData Dictionary of metadata to store with a dispatch call, can be used later on
	 */
  public setMetadata(metaData: Record<string, string>): this {
    this.data.metaData = metaData;
    return this;
  }

  /**
	 * Sets specified units for this dispatch call
   * @param units Units to be removed from a call
	 */
  public setUnits(units: string[]): this {
    this.data.units = units;
    return this;
  }

  /**
	 * Adds specified units from this dispatch call
   * @param units Units to be removed from a call
	 */
  public addUnits(...units: string[]): this {
    this.data.units?.push(...units);
    return this;
  }

  /**
	 * Removes specified units from this dispatch call
   * @param units Units to be removed from a call
	 */
  public removeUnits(...units: string[]): this {
    this.data.units?.filter((unit) => !units.includes(unit));
    return this;
  }

  /**
	 * Transforms the dispatch call to a plain object
	 */
  public toJSON(): CADNewDispatchBuilderOptions{
    return { ...this.data };
  }
}