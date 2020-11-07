package com.watchn.orders.web.payload;

import lombok.Data;

@Data
public class ExistingOrder extends Order {
    private String id;
}
