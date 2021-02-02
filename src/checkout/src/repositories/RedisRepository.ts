import { createHandyClient, IHandyRedis } from 'handy-redis';
import { IRepository } from './IRepository';

export class RedisRepository implements IRepository {

  private _client : IHandyRedis;

  private _readClient : IHandyRedis;

  constructor(private url: string, private readerUrl: string) { }

  client() {
    if(!this._client) {
      this._client = createHandyClient(this.url);
    }
    return this._client;
  }

  readClient() {
    if(!this._readClient) {
      this._readClient = createHandyClient(this.readerUrl);
    }
    return this._readClient;
  }

  async get(key : string) : Promise<string> {
    return this.readClient().get(key);
  }

  async set(key : string, value : string) : Promise<string> {
    return this.client().set(key, value);
  }

  async remove(key : string) : Promise<void> {
    await this.client().del(key);

    return Promise.resolve(null);
  }

  async health() {
    // something like this:
    // https://github.com/dannydavidson/k8s-neo-api/blob/master/annotely-graph/apps/ops/health.js
    return true;
  }

}