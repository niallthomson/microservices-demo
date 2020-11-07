import { IsOptional, IsString } from 'class-validator';

export class ShippingAddress {

  @IsString()
  address1 : string;

  @IsString()
  @IsOptional()
  address2 : string;

  @IsString()
  city : string;

  @IsString()
  state : string;

  @IsString()
  zip : string;

}