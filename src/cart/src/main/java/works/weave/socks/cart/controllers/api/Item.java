package works.weave.socks.cart.controllers.api;

import lombok.Data;
import works.weave.socks.cart.repositories.ItemEntity;

@Data
public class Item {
    private String itemId;

    private int quantity;

    private float unitPrice;

    public static Item from(ItemEntity itemEntity) {
        Item item = new Item();
        item.itemId = itemEntity.getItemId();
        item.quantity = itemEntity.getQuantity();
        item.unitPrice = itemEntity.getUnitPrice();

        return item;
    }
}
