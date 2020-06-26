package works.weave.socks.cart.repositories.mongo.entities;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import works.weave.socks.cart.repositories.ItemEntity;

import javax.validation.constraints.NotNull;

@Document
@Data
public class MongoItemEntity implements ItemEntity {
    @Id
    private String id;

    @NotNull(message = "Item Id must not be null")
    private String itemId;
    private int quantity;
    private float unitPrice;

    public MongoItemEntity(String id, String itemId, int quantity, float unitPrice) {
        this.id = id;
        this.itemId = itemId;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
    }

    public MongoItemEntity() {
        this(null, "", 1, 0F);
    }

    public MongoItemEntity(String itemId) {
        this(null, itemId, 1, 0F);
    }

    public MongoItemEntity(MongoItemEntity item, String id) {
        this(id, item.itemId, item.quantity, item.unitPrice);
    }

    public MongoItemEntity(MongoItemEntity item, int quantity) {
        this(item.id(), item.itemId, quantity, item.unitPrice);
    }

    public String id() {
        return id;
    }

    public String itemId() {
        return itemId;
    }

    public int quantity() {
        return quantity;
    }
}