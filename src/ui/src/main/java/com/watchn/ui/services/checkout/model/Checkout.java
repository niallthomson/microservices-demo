package com.watchn.ui.services.checkout.model;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class Checkout {
    private String paymentToken;

    private int tax;

    private int total;
}
