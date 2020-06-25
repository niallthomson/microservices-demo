package works.weave.socks.cart.repositories.mongo.entities;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.DBRef;
import org.springframework.data.mongodb.core.mapping.Document;
import works.weave.socks.cart.repositories.CartEntity;
import works.weave.socks.cart.repositories.ItemEntity;

import javax.validation.constraints.NotNull;
import java.util.ArrayList;
import java.util.List;

@Document
@Data
public class MongoCartEntity implements CartEntity {
    @Id
    private String id;

    @DBRef
    private List<MongoItemEntity> items = new ArrayList<>();

    public MongoCartEntity(String customerId) {
        this.id = customerId;
    }

    public MongoCartEntity() {
        this(null);
    }

    public List<MongoItemEntity> contents() {
        return items;
    }

    public MongoCartEntity add(MongoItemEntity item) {
        items.add(item);
        return this;
    }

    public MongoCartEntity remove(MongoItemEntity item) {
        items.remove(item);
        return this;
    }

    public String getCustomerId() {
        return this.id;
    }
}
