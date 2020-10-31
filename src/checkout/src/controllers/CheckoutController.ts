import { Checkout } from '../models/Checkout';
import { CheckoutRequest } from '../models/CheckoutRequest';
import { CheckoutSubmitted } from '../models/CheckoutSubmitted';
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

  @Post('/:customerId/update')
  @OpenAPI({ summary: 'Create or update a customers checkout' })
  @ResponseSchema(Checkout)
  async updateCheckout(@Param('customerId') customerId: string, @Body({ validate: true }) request: CheckoutRequest) : Promise<Checkout> {
    return this.checkoutService.update(customerId, request);
  }

  @Post('/:customerId/submit')
  @OpenAPI({ summary: 'Submits a customers checkout to create an order' })
  @ResponseSchema(CheckoutSubmitted)
  async submitCheckout(@Param('customerId') customerId: string) : Promise<CheckoutSubmitted> {
    return this.checkoutService.submit(customerId);
  }
}