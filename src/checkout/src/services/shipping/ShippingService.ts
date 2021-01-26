import Container from 'typedi';
import * as config from 'config';
import { IShippingService } from './IShippingService';
import { MockShippingService } from './MockShippingService';

export function ShippingService() {
  return function(object: Object, propertyName: string, index?: number) {
    const ordersEndpoint = config.get('endpoints.orders').toString();

    let service : IShippingService;

    service = new MockShippingService();

    Container.registerHandler({ object, propertyName, index, value: (containerInstance) => service });
  };
}