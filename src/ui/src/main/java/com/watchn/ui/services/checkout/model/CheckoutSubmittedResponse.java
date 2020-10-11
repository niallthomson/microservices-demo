package com.watchn.ui.services.checkout.model;

import com.watchn.ui.services.carts.model.Cart;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class CheckoutSubmittedResponse {
    private CheckoutSubmitted submitted;

    private Cart cart;
}
