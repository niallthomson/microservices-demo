import { Checkout } from '../models/Checkout';
import { Inject, Service } from 'typedi';
import { IRepository } from '../repositories/IRepository';
import { CheckoutRequest } from '../models/CheckoutRequest';
import { serialize , deserialize} from 'class-transformer';
import { Repository } from '../repositories/Repository';
import { IShippingService } from './shipping/IShippingService';
import { CheckoutSubmitted } from '../models/CheckoutSubmitted';
import { IOrdersService } from './orders/IOrdersService';
import { OrdersService } from './orders/OrdersService';
import { ShippingService } from './shipping/ShippingService';

@Service()
export class CheckoutService {

  constructor(@Repository() private repository : IRepository, @ShippingService() private shippingService : IShippingService, @OrdersService() private ordersService : IOrdersService) {
  }

  async get(customerId: string) : Promise<Checkout> {
    const json = await this.repository.get(customerId);

    if(!json) {
      return null;
    }

    return deserialize(Checkout, json);
  }

  async update(customerId: string, request : CheckoutRequest) : Promise<Checkout> {
    const tax = request.shippingAddress ? Math.floor(request.subtotal * 0.05) : -1; // Hardcoded 5% tax for now
    const effectiveTax = tax == -1 ? 0 : tax;

    return this.shippingService.getShippingRates(request).then(async (shippingRates) => {
      let shipping = -1;

      if(shippingRates) {
        console.log('Query shipping rates')
        for ( let i = 0; i < shippingRates.rates.length; i++ ) {
          if(shippingRates.rates[i].token == request.deliveryOptionToken) {
            console.log('Found shipping rate')
            shipping = shippingRates.rates[i].amount;
          }
        }
      }

      const checkout : Checkout =  {
        shippingRates,
        request,
        paymentId: this.makeid(16),
        paymentToken: this.makeid(32),
        shipping,
        tax,
        total: request.subtotal + effectiveTax,
      };

      await this.repository.set(customerId, serialize(checkout));

      return checkout;
    });
  }

  async submit(customerId: string) : Promise<CheckoutSubmitted> {
    let checkout = await this.get(customerId);

    if(!checkout) {
      throw new Error('Checkout not found');
    }

    let order = await this.ordersService.create(checkout);

    await this.repository.remove(customerId);

    return Promise.resolve({
      orderId: order.id,
      customerEmail: checkout.request.customerEmail
    });
  }

  private makeid(length) {
    let result             = '';
    const characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    const charactersLength = characters.length;
    for ( let i = 0; i < length; i++ ) {
       result += characters.charAt(Math.floor(Math.random() * charactersLength));
    }
    return result;
  }
}