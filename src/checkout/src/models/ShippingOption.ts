import { IsNumber, IsString } from "class-validator";

export class ShippingOption {

  @IsString()
  name : string;

  @IsNumber()
  amount : number;

  @IsString()
  token : string;

}