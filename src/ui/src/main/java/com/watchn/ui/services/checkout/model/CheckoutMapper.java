package com.watchn.ui.services.checkout.model;

import org.mapstruct.Mapper;

@Mapper
public interface CheckoutMapper {
    Checkout checkout(com.watchn.ui.clients.checkout.model.Checkout checkout);

    CheckoutSubmitted submitted(com.watchn.ui.clients.checkout.model.CheckoutSubmitted submitted);
}
