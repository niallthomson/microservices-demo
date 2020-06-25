package works.weave.socks.cart.repositories.dynamo.entities;

import com.amazonaws.services.dynamodbv2.datamodeling.*;
import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import works.weave.socks.cart.repositories.ItemEntity;

import javax.validation.constraints.NotNull;

@DynamoDBTable(tableName="Items")
public class DynamoItemEntity implements ItemEntity {
    private String id;

    private String customerId;

    private String itemId;

    private int quantity;

    private float unitPrice;

    public DynamoItemEntity(String id, String customerId, String itemId, int quantity, float unitPrice) {
        this.id = id;
        this.customerId = customerId;
        this.itemId = itemId;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
    }

    public DynamoItemEntity() {

    }

    @DynamoDBHashKey
    public String getId() {
        return id;
    }

    @DynamoDBAttribute
    @DynamoDBIndexHashKey(globalSecondaryIndexName = "idx_global_customerId")
    public String getCustomerId() {
        return customerId;
    }

    @DynamoDBAttribute
    public String getItemId() {
        return itemId;
    }

    @DynamoDBAttribute
    public int getQuantity() {
        return quantity;
    }

    @DynamoDBAttribute
    public float getUnitPrice() {
        return unitPrice;
    }

    public void setId(String id) {
        this.id = id;
    }

    public void setCustomerId(String id) {
        this.customerId = id;
    }

    public void setItemId(String itemId) {
        this.itemId = itemId;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public void setUnitPrice(float unitPrice) {
        this.unitPrice = unitPrice;
    }
}
