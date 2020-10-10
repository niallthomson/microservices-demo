import { createHandyClient, IHandyRedis } from 'handy-redis';
import { IRepository } from './IRepository';

export class RedisRepository implements IRepository {

  private _client : IHandyRedis

  constructor(private url: string) { }

  client() {
    if(!this._client) {
      this._client = createHandyClient(this.url);
    }
    return this._client;
  }

  async get(key : string) : Promise<string> {
    return this.client().get(key);
  }

  async set(key : string, value : string) : Promise<string> {
    return this.client().set(key, value);
  }

  async health() {
    // something like this:
    // https://github.com/dannydavidson/k8s-neo-api/blob/master/annotely-graph/apps/ops/health.js
    return true;
  }

}