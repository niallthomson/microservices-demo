import { Checkout } from '../models/Checkout'
import { CheckoutRequest } from '../models/CheckoutRequest'
import { CheckoutService } from '../services/CheckoutService';
import {
  Body,
  Get,
  JsonController,
  Param,
  Post
} from 'routing-controllers'
import { OpenAPI, ResponseSchema } from 'routing-controllers-openapi'
import { Inject } from 'typedi';

@OpenAPI({})
@JsonController('/checkout')
export class CheckoutController {

  @Inject()
  checkoutService: CheckoutService;

  @Get('/:customerId')
  @OpenAPI({ summary: 'Return customers checkout' })
  @ResponseSchema(Checkout)
  async getCheckout(@Param('customerId') customerId: string) : Promise<Checkout> {
    return this.checkoutService.get(customerId);
  }

  @Post('/:customerId')
  @OpenAPI({ summary: 'Create or update a customers checkout' })
  async updateCheckout(@Param('customerId') customerId: string, @Body({ validate: true }) request: CheckoutRequest) : Promise<Checkout> {
    return this.checkoutService.update(customerId, request);
  }
}