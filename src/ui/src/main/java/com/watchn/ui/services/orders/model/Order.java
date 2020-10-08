package com.watchn.ui.services.orders.model;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class Order {
    private long id;

    private String email;
}
