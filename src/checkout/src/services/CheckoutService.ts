import { Checkout } from "../models/Checkout";
import { Inject, Service } from "typedi";
import { Redis } from "../config/Redis";
import { CheckoutRequest } from "../models/CheckoutRequest";
import { serialize , deserialize} from 'class-transformer';

@Service()
export class CheckoutService {

  @Inject()
  redis : Redis;

  async get(customerId: string) : Promise<Checkout> {
    let json = await this.redis.get(customerId)

    return deserialize(Checkout, json);
  }

  async update(customerId: string, request : CheckoutRequest) : Promise<Checkout> {
    let checkout : Checkout = {
      shippingOptions: [],
      request: request,
      paymentId: "dummy",
      paymentToken: "dummy",
      tax: 20,
      total: 1234
    }

    await this.redis.set(customerId, serialize(checkout));

    return checkout;
  }

}