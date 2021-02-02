import Container from 'typedi';
import * as config from 'config';
import { IRepository } from './IRepository';
import { RedisRepository } from './RedisRepository';
import { InMemoryRepository } from './InMemoryRepository';

export function Repository() {
  return function(object: Object, propertyName: string, index?: number) {
    let redisUrl = config.get('redis.url').toString();
    let redisReaderUrl = config.get('redis.reader.url').toString();

    if(!redisReaderUrl) {
      redisReaderUrl = redisUrl;
    }

    let repository : IRepository;

    if(redisUrl) {
      console.log('Creating RedisRepository...');
      repository = new RedisRepository(redisUrl, redisReaderUrl);
    }
    else {
      console.log('Creating InMemoryRepository...');
      repository = new InMemoryRepository();
    }

    Container.registerHandler({ object, propertyName, index, value: (containerInstance) => repository });
  };
}