import { Checkout } from '../models/Checkout';
import { CheckoutRequest } from '../models/CheckoutRequest';
import { CheckoutService } from '../services/CheckoutService';
import {
  Body,
  Get,
  JsonController,
  NotFoundError,
  Param,
  Post
} from 'routing-controllers';
import { OpenAPI, ResponseSchema } from 'routing-controllers-openapi';

@OpenAPI({})
@JsonController('/checkout')
export class CheckoutController {

  constructor(private checkoutService: CheckoutService) {
  }

  @Get('/:customerId')
  @OpenAPI({ summary: 'Return customers checkout' })
  @ResponseSchema(Checkout)
  async getCheckout(@Param('customerId') customerId: string) : Promise<Checkout> {
    const checkout = this.checkoutService.get(customerId);

    return checkout.then(function(data) {
      if(!data) {
        throw new NotFoundError('Checkout not found');
      }

      return data;
    });
  }

  @Post('/:customerId')
  @OpenAPI({ summary: 'Create or update a customers checkout' })
  async updateCheckout(@Param('customerId') customerId: string, @Body({ validate: true }) request: CheckoutRequest) : Promise<Checkout> {
    return this.checkoutService.update(customerId, request);
  }
}