package com.watchn.orders.web.payload;

import lombok.Data;

import java.util.List;

@Data
public class CreateOrderRequest {
    private String firstName;

    private String lastName;

    private List<CreateOrderRequestItem> items;
}
