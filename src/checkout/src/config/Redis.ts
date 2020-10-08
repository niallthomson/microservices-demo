import { createHandyClient, IHandyRedis } from 'handy-redis';
import { Service } from "typedi";
import * as config from 'config';
import * as redis from "redis";

@Service()
export class Redis {

  private _client : IHandyRedis
  private url: string = config.get('redis.url').toString();

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