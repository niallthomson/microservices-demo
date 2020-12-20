import { Checkout } from '../models/Checkout';
import { Service } from 'typedi';
import { ExistingOrder, Order, OrdersApi } from '../clients/orders/api';
import * as config from 'config';

@Service()
export class OrdersService {

  private ordersApi : OrdersApi;

  constructor() {
    let endpoint = config.get('endpoints.orders');

    this.ordersApi = new OrdersApi(endpoint+"");
  }

  async create(checkout : Checkout) : Promise<ExistingOrder> {
    return this.ordersApi.createOrder({
      email: checkout.request.customerEmail,
      firstName: "John",
      lastName: "Doe",
      items: []
    }).then((value) => {
      return value.body;
    });
  }
}