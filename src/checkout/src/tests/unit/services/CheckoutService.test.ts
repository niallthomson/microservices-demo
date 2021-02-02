import 'reflect-metadata'
import { expect } from 'chai';
import { CheckoutService } from '../../../services/CheckoutService';
import { IShippingService } from '../../../services/shipping/IShippingService';
import { IRepository } from '../../../repositories/IRepository';
import { Checkout } from '../../../models/Checkout';
import { CheckoutRequest } from '../../../models/CheckoutRequest';
import { when } from 'jest-when'
import { Item } from '../../../models/Item';

describe('CheckoutService', () => {
  const mockedRepository: jest.Mocked<IRepository> = {
    get: jest.fn(),
    set: jest.fn(),
    remove: jest.fn()
  }

  const mockedShippingService: jest.Mocked<IShippingService> = {
    getShippingRates: jest.fn()
  }

  beforeEach(() => {
    mockedRepository.get.mockClear();

    const request = new CheckoutRequest();
    request.customerEmail = "dummy";

    const checkout = new Checkout();
    checkout.request = request;

    when(mockedRepository.get).calledWith('a').mockResolvedValue(JSON.stringify(checkout));

    mockedShippingService.getShippingRates.mockReturnValue(Promise.resolve({
      shipmentId: "123",
      rates: [{
        name: "Priority Mail",
        amount: 5,
        token: "priority-mail",
        estimatedDays: 10
      }]
    }));
  });

  it('retrieves an existing checkout', async () => {
    const service = new CheckoutService(mockedRepository, mockedShippingService, null);

    const response = await service.get('a');

    expect(response.request.customerEmail).to.equal('dummy');
  });

  it('retrieves an missing checkout', async () => {
    const service = new CheckoutService(mockedRepository, mockedShippingService, null);

    const response = await service.get('b');

    expect(response).to.equal(null);
  });

  it('processes checkout update', async () => {
    const service = new CheckoutService(mockedRepository, mockedShippingService, null);

    const item = new Item();
    item.id = "123"
    item.name = "item1";
    item.quantity = 2;
    item.unitCost = 123;
    item.totalCost = 246;
    item.imageUrl = "url";

    const request = new CheckoutRequest();
    request.customerEmail = "dummy";
    request.items = [
      item
    ];
    request.subtotal = 246;

    const response = await service.update('c', request);

    expect(response.request.customerEmail).to.equal('dummy');
    expect(response.request.items.length).to.equal(1);
    expect(response.tax).to.equal(-1);
    expect(response.shipping).to.equal(-1);
    expect(response.total).to.equal(246);
  });
});