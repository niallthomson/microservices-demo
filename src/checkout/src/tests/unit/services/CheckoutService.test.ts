import 'reflect-metadata'
import { expect } from 'chai';
import { CheckoutService } from '../../../services/CheckoutService';
import { IShippingService } from '../../../services/shipping/IShippingService';
import { IRepository } from '../../../repositories/IRepository';
import { Checkout } from '../../../models/Checkout';
import { CheckoutRequest } from '../../../models/CheckoutRequest';

describe('CheckoutService', () => {
  const mockedRepository: jest.Mocked<IRepository> = {
    get: jest.fn(),
    set: jest.fn()
  }

  const mockedShippingService: jest.Mocked<IShippingService> = {
    getShippingRates: jest.fn()
  }

  const setup = () => {
    const request = new CheckoutRequest();
    request.customerEmail = "dummy";

    const checkout = new Checkout();
    checkout.request = request;

    mockedRepository.get.mockResolvedValue(JSON.stringify(checkout));
  };

  beforeEach(() => {
    mockedRepository.get.mockClear();
  });

  it('retrieves an existing checkout', async () => {
    setup();
    
    const service = new CheckoutService(mockedRepository, mockedShippingService, null);

    const response = await service.get("a");

    expect(response.request.customerEmail).to.equal('dummy');
  });
});