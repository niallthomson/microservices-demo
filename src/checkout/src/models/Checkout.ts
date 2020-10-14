import { Type } from 'class-transformer';
import { IsInt, IsString, Min, ValidateNested } from 'class-validator';
import { CheckoutRequest } from './CheckoutRequest';
import { ShippingOption } from './ShippingOption';

export class Checkout {

  @ValidateNested()
  @Type(() => CheckoutRequest)
  request : CheckoutRequest;

  @ValidateNested({ each: true })
  @Type(() => ShippingOption)
  shippingOptions : ShippingOption[];

  @IsString()
  paymentId : string;

  @IsString()
  paymentToken : string;

  @IsInt()
  @Min(0)
  tax : number;

  @IsInt()
  @Min(0)
  total : number;

}