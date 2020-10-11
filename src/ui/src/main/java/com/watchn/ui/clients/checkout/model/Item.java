/*
 * Checkout API
 * Checkout API
 *
 * The version of the OpenAPI document: 1.0.0
 * 
 *
 * NOTE: This class is auto generated by OpenAPI Generator (https://openapi-generator.tech).
 * https://openapi-generator.tech
 * Do not edit the class manually.
 */


package com.watchn.ui.clients.checkout.model;

import java.util.Objects;
import java.util.Arrays;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;

/**
 * Item
 */
@JsonPropertyOrder({
  Item.JSON_PROPERTY_ID,
  Item.JSON_PROPERTY_QUANTITY,
  Item.JSON_PROPERTY_UNIT_COST,
  Item.JSON_PROPERTY_TOTAL_COST
})
@javax.annotation.Generated(value = "org.openapitools.codegen.languages.JavaClientCodegen", date = "2020-10-10T22:27:39.185657-07:00[America/Los_Angeles]")
public class Item {
  public static final String JSON_PROPERTY_ID = "id";
  private String id;

  public static final String JSON_PROPERTY_QUANTITY = "quantity";
  private Integer quantity;

  public static final String JSON_PROPERTY_UNIT_COST = "unitCost";
  private Integer unitCost;

  public static final String JSON_PROPERTY_TOTAL_COST = "totalCost";
  private Integer totalCost;


  public Item id(String id) {
    
    this.id = id;
    return this;
  }

   /**
   * Get id
   * @return id
  **/
  @ApiModelProperty(required = true, value = "")
  @JsonProperty(JSON_PROPERTY_ID)
  @JsonInclude(value = JsonInclude.Include.ALWAYS)

  public String getId() {
    return id;
  }


  public void setId(String id) {
    this.id = id;
  }


  public Item quantity(Integer quantity) {
    
    this.quantity = quantity;
    return this;
  }

   /**
   * Get quantity
   * minimum: 0
   * @return quantity
  **/
  @ApiModelProperty(required = true, value = "")
  @JsonProperty(JSON_PROPERTY_QUANTITY)
  @JsonInclude(value = JsonInclude.Include.ALWAYS)

  public Integer getQuantity() {
    return quantity;
  }


  public void setQuantity(Integer quantity) {
    this.quantity = quantity;
  }


  public Item unitCost(Integer unitCost) {
    
    this.unitCost = unitCost;
    return this;
  }

   /**
   * Get unitCost
   * minimum: 0
   * @return unitCost
  **/
  @ApiModelProperty(required = true, value = "")
  @JsonProperty(JSON_PROPERTY_UNIT_COST)
  @JsonInclude(value = JsonInclude.Include.ALWAYS)

  public Integer getUnitCost() {
    return unitCost;
  }


  public void setUnitCost(Integer unitCost) {
    this.unitCost = unitCost;
  }


  public Item totalCost(Integer totalCost) {
    
    this.totalCost = totalCost;
    return this;
  }

   /**
   * Get totalCost
   * minimum: 0
   * @return totalCost
  **/
  @ApiModelProperty(required = true, value = "")
  @JsonProperty(JSON_PROPERTY_TOTAL_COST)
  @JsonInclude(value = JsonInclude.Include.ALWAYS)

  public Integer getTotalCost() {
    return totalCost;
  }


  public void setTotalCost(Integer totalCost) {
    this.totalCost = totalCost;
  }


  @Override
  public boolean equals(java.lang.Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    Item item = (Item) o;
    return Objects.equals(this.id, item.id) &&
        Objects.equals(this.quantity, item.quantity) &&
        Objects.equals(this.unitCost, item.unitCost) &&
        Objects.equals(this.totalCost, item.totalCost);
  }

  @Override
  public int hashCode() {
    return Objects.hash(id, quantity, unitCost, totalCost);
  }


  @Override
  public String toString() {
    StringBuilder sb = new StringBuilder();
    sb.append("class Item {\n");
    sb.append("    id: ").append(toIndentedString(id)).append("\n");
    sb.append("    quantity: ").append(toIndentedString(quantity)).append("\n");
    sb.append("    unitCost: ").append(toIndentedString(unitCost)).append("\n");
    sb.append("    totalCost: ").append(toIndentedString(totalCost)).append("\n");
    sb.append("}");
    return sb.toString();
  }

  /**
   * Convert the given object to string with each line indented by 4 spaces
   * (except the first line).
   */
  private String toIndentedString(java.lang.Object o) {
    if (o == null) {
      return "null";
    }
    return o.toString().replace("\n", "\n    ");
  }

}
