package com.watchn.carts.controllers.api;

import com.watchn.carts.repositories.ItemEntity;
import lombok.Data;

@Data
public class Item {
    private String itemId;

    private int quantity;

    private int unitPrice;

    public static Item from(ItemEntity itemEntity) {
        Item item = new Item();
        item.itemId = itemEntity.getItemId();
        item.quantity = itemEntity.getQuantity();
        item.unitPrice = itemEntity.getUnitPrice();

        return item;
    }
}
