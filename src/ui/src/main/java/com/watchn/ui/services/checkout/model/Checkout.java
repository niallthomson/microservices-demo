package com.watchn.ui.services.checkout.model;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.List;

@Data
@AllArgsConstructor
public class Checkout {
    private String paymentToken;

    private int subtotal;

    private int tax;

    private int shipping;

    private int total;

    private List<ShippingOption> shippingOptions;
}
