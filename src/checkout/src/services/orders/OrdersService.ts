import Container from 'typedi';
import * as config from 'config';
import { IOrdersService } from './IOrdersService';
import { HttpOrdersService } from './HttpOrdersService';
import { MockOrdersService } from './MockOrdersService';

export function OrdersService() {
  return function(object: Object, propertyName: string, index?: number) {
    const ordersEndpoint = config.get('endpoints.orders').toString();

    let service : IOrdersService;

    if(ordersEndpoint) {
      console.log('Creating HttpOrdersService...');
      service = new HttpOrdersService(ordersEndpoint);
    }
    else {
      console.log('Creating MockOrdersService...');
      service = new MockOrdersService();
    }

    Container.registerHandler({ object, propertyName, index, value: (containerInstance) => service });
  };
}