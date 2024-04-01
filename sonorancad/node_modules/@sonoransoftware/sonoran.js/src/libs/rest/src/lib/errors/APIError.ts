export class APIError extends Error {
  public constructor(
    public response: string,
    public requestType: string,
    public requestUrl: string,
    public responseCode: number,
    public requestData: any
  ) {
    super(response);
  }

  public override get name(): string {
    return `Sonoran.js API Error - ${this.requestType} [${this.responseCode}]`;
  }
}