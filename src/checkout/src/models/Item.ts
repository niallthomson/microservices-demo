import { IsString, IsInt, Min } from 'class-validator'

export class Item {

  @IsString()
  id : string;

  @IsInt()
  @Min(0)
  quantity : number;

  @IsInt()
  @Min(0)
  unitCost : number;

  @IsInt()
  @Min(0)
  totalCost : number;

}