import { runInThisContext } from 'vm';
import { IRepository } from './IRepository';

export class InMemoryRepository implements IRepository {

  map = new Map<string, string>(); 

  async get(key : string) : Promise<string> {
    if(this.map.has(key)) {
      return Promise.resolve(this.map.get(key));
    }

    return null;
  }

  async set(key : string, value : string) : Promise<string> {
    this.map.set(key, value);

    return Promise.resolve(value);
  }

  async remove(key : string) : Promise<void> {
    this.map.delete(key);

    return Promise.resolve(null);
  }
}