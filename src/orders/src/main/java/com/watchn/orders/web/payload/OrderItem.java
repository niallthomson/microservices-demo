package com.watchn.orders.web.payload;

import lombok.Data;

@Data
public class OrderItem {
    private String productId;

    private int quantity;

    private int price;
}
