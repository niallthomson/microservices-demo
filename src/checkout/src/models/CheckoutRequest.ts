import { Type } from 'class-transformer';
import { ValidateNested, IsEmail, IsInt, Min } from 'class-validator';

import { Item } from './Item';
import { ShippingAddress } from './ShippingAddress';

export class CheckoutRequest {

  @IsEmail()
  customerEmail : string;

  @ValidateNested({ each: true })
  @Type(() => Item)
  items : Item[];

  @ValidateNested()
  @Type(() => ShippingAddress)
  shippingAddress : ShippingAddress;

  @IsInt()
  @Min(0)
  subtotal : number;

}