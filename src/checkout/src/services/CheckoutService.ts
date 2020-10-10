import { Checkout } from "../models/Checkout";
import { Service } from "typedi";
import { IRepository } from "../repositories/IRepository";
import { CheckoutRequest } from "../models/CheckoutRequest";
import { serialize , deserialize} from 'class-transformer';
import { Repository } from "../repositories/Repository";

@Service()
export class CheckoutService {

  constructor(@Repository() private redis : IRepository) {
  }

  async get(customerId: string) : Promise<Checkout> {
    let json = await this.redis.get(customerId)

    if(!json) {
      return null;
    }

    return deserialize(Checkout, json);
  }

  async update(customerId: string, request : CheckoutRequest) : Promise<Checkout> {
    let tax = Math.floor(request.subtotal * 0.05); // Hardcoded 5% tax for now

    let checkout : Checkout = {
      shippingOptions: [],
      request: request,
      paymentId: this.makeid(16),
      paymentToken: this.makeid(32),
      tax: tax,
      total: request.subtotal + tax,
    }

    await this.redis.set(customerId, serialize(checkout));

    return checkout;
  }

  private makeid(length) {
    let result           = '';
    let characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let charactersLength = characters.length;
    for ( var i = 0; i < length; i++ ) {
       result += characters.charAt(Math.floor(Math.random() * charactersLength));
    }
    return result;
  }
}