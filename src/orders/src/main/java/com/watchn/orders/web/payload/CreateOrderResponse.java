package com.watchn.orders.web.payload;

import lombok.Data;

@Data
public class CreateOrderResponse {
    private long id;

    public CreateOrderResponse(long id) {
        this.id = id;
    }
}
