package com.watchn.ui.web.payload;

import com.watchn.ui.clients.carts.model.Item;
import com.watchn.ui.clients.catalog.model.ModelProduct;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class CartItem {
    private String id;

    private int quantity;

    private int price;

    private String name;

    private String imageUrl;

    public static CartItem from(Item item, ModelProduct product) {
        return new CartItem(product.getId(),
                item.getQuantity(), product.getPrice(),
                product.getName(), product.getImageUrl());
    }

    public int getTotalPrice() {
        return this.quantity * this.price;
    }
}
